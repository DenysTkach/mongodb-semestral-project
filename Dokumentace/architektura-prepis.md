# Přepis úvodu a kapitoly Architektura

Níže je čitelnější verze úvodu a architektonické části dokumentace. Text je napsán tak, aby se dal vložit do Word dokumentu místo současných dlouhých odstavců.

## Úvod

Tato semestrální práce se zabývá dokumentovou NoSQL databází MongoDB a jejím použitím pro ukládání a analytické zpracování sportovních dat.

Praktická část práce je postavena jako distribuované databázové řešení. MongoDB cluster je spuštěn pomocí Docker Compose a obsahuje sharding, replikaci, perzistenci dat, autentizaci, autorizaci, validační schémata a indexy.

Jako datový zdroj jsou použita veřejná data StatsBomb Open Data. Konkrétně se pracuje s fotbalovými daty ze soutěže La Liga pro sezonu 2019/2020. Data jsou po předzpracování rozdělena do tří propojených kolekcí:

| Kolekce | Účel | Počet dokumentů |
|---|---:|---:|
| `matches` | informace o zápasech | 33 |
| `players` | informace o hráčích | 476 |
| `events` | herní události v zápasech | 129 058 |

Největší a nejdůležitější kolekcí je `events`. Tato kolekce obsahuje jednotlivé herní události, například přihrávky, střely, fauly nebo držení míče. Proto je právě tato kolekce shardována mezi tři shardy.

Čtenář se v práci seznámí s návrhem MongoDB clusteru, jeho spuštěním pomocí Dockeru, způsobem importu dat, nastavením shardingu a replikace, zabezpečením databáze a příklady netriviálních MongoDB dotazů.

Součástí práce není vývoj webové aplikace ani vizualizační dashboard. Projekt je zaměřen na samotnou databázovou infrastrukturu, přípravu dat, dotazování a ověření funkčnosti distribuovaného řešení.

V projektu je použita MongoDB ve verzi `8.0.20` z oficiálního Docker image `mongo:8.0.20`. Tato verze splňuje požadavek zadání na použití aktuální podporované verze databáze.

## 1 Architektura

Tato kapitola popisuje architekturu MongoDB clusteru, důvod zvolené topologie a konkrétní konfiguraci jednotlivých částí řešení.

Celé řešení je spuštěno jako jeden sharded MongoDB cluster. Cluster běží v kontejnerech pomocí Docker Compose. Klient se nepřipojuje přímo na jednotlivé shardy, ale přes službu `mongos`, která funguje jako router.

### 1.1 Schéma a popis architektury

Navržená architektura obsahuje tyto hlavní části:

| Komponenta | Počet | Název v projektu | Úloha |
|---|---:|---|---|
| Config server | 3 | `configsvr01`, `configsvr02`, `configsvr03` | ukládá metadata clusteru |
| Shard replica set | 3 | `shard01rs`, `shard02rs`, `shard03rs` | ukládá aplikační data |
| Uzly ve shardu | 9 | `shard01a` až `shard03c` | replikované databázové uzly |
| Router | 1 | `mongos-router` | vstupní bod do clusteru |
| Inicializační služba | 1 | `cluster-setup` | automatické nastavení clusteru |
| Keyfile služba | 1 | `keyfile-setup` | vytvoření interního keyfile |

Celkem databázová část obsahuje 13 MongoDB instancí:

- 3 config servery,
- 9 shardových uzlů,
- 1 `mongos` router.

Config servery tvoří replica set `configReplSet`. Jejich úkolem je ukládat metadata o shardech, chunkách a shardovaných kolekcích. Bez config serverů by `mongos` nevěděl, na kterém shardu se nachází konkrétní část dat.

Aplikační data jsou uložena ve třech shardech:

| Shard | Uzly | Úloha |
|---|---|---|
| `shard01rs` | `shard01a`, `shard01b`, `shard01c` | první část shardovaných dat |
| `shard02rs` | `shard02a`, `shard02b`, `shard02c` | druhá část shardovaných dat |
| `shard03rs` | `shard03a`, `shard03b`, `shard03c` | třetí část shardovaných dat |

Každý shard je zároveň replica set. To znamená, že každý shard má jeden primární uzel a dva sekundární uzly. Primární uzel přijímá zápisy a sekundární uzly drží kopie dat.

Router `mongos-router` je jediný veřejný vstup do clusteru. V projektu je vystaven na portu `27030`. Klient nebo administrátor se připojuje na tento router a router následně podle metadat rozhoduje, na které shardy má dotaz poslat.

Tato architektura odpovídá doporučenému způsobu nasazení MongoDB sharded clusteru, ale je přizpůsobena rozsahu semestrální práce. V produkčním prostředí by bylo vhodné použít více `mongos` routerů kvůli vyšší dostupnosti. V tomto projektu je použit jeden router, protože cílem je přehledně demonstrovat principy shardingu, replikace a automatizovaného nasazení.

### 1.2 Specifika konfigurace

Konfigurace clusteru je navržena tak, aby splnila požadavky zadání a současně odpovídala charakteru použitých dat.

Největší objem dat je v kolekci `events`, která obsahuje 129 058 dokumentů. Proto je hlavní důraz kladen na shardování této kolekce. Menší kolekce `matches` a `players` slouží hlavně jako doplňující kolekce pro analytické dotazy a spojování přes `$lookup`.

Všechny služby běží v jedné Docker síti `mongo-cluster`. Každý databázový uzel má vlastní Docker volume pro perzistentní uložení dat. Konfigurace MongoDB je rozdělena do samostatných souborů pro config servery, shard servery a router `mongos`.

#### 1.2.1 CAP teorém

Z pohledu CAP teorému je toto řešení nejblíže modelu CP, tedy konzistenci a toleranci vůči rozdělení sítě.

MongoDB v replica setu preferuje správnou volbu primárního uzlu a konzistentní zápisy. Pokud vypadne primární uzel, cluster krátkodobě omezí zápisy, dokud neproběhne volba nového primárního uzlu.

Pro tento projekt je tento přístup vhodný. Data nejsou zapisována jako živý datový stream v reálném čase, ale jsou importována dávkově z připravených JSON souborů. Proto je důležitější správnost a konzistence dat než absolutní dostupnost zápisů za každé situace.

Krátká nedostupnost během failoveru je pro analytické sportovní údaje přijatelná. Po zvolení nového primárního uzlu může cluster pokračovat v práci.

#### 1.2.2 Cluster

V projektu je použit jeden MongoDB cluster.

Jeden cluster je pro semestrální práci dostačující, protože umožňuje ukázat všechny požadované vlastnosti:

- sharding,
- replikaci,
- config servery,
- router `mongos`,
- autentizaci a autorizaci,
- validační schémata,
- indexaci,
- analytické dotazování.

Všechna data jsou uložena v databázi `statsbomb`. Tato databáze obsahuje tři hlavní kolekce: `matches`, `players` a `events`.

Použití jednoho clusteru také zjednodušuje obhajobu. Při kontrole lze jednoznačně ukázat, kde jsou data uložena, jak jsou rozdělena mezi shardy a jak nad nimi fungují dotazy.

#### 1.2.3 Uzly

Cluster obsahuje více než minimálně požadované tři uzly. Celkově je použito 13 MongoDB instancí.

| Typ uzlu | Počet | Popis |
|---|---:|---|
| Config server | 3 | metadata clusteru |
| Shardové uzly | 9 | aplikační data |
| Mongos router | 1 | směrování požadavků |

Každý shard obsahuje tři uzly. Jeden z nich je primární a dva jsou sekundární. Tato konfigurace umožňuje demonstrovat replikaci i výpadek jednoho uzlu.

Počet uzlů je zvolen tak, aby řešení splňovalo požadavky na vysokou dostupnost, sharding a replikaci, ale zároveň zůstalo spustitelné na běžném studentském zařízení pomocí Dockeru.

#### 1.2.4 Sharding

Sharding je použit pro kolekci `events`.

Tato kolekce je největší částí projektu a obsahuje 129 058 dokumentů. Proto je vhodná pro ukázku horizontálního rozdělení dat mezi více shardů.

Shardovací klíč je:

```javascript
{ event_id: "hashed" }
```

Pole `event_id` bylo zvoleno proto, že je unikátní a má vysokou kardinalitu. Hashovaný shardovací klíč pomáhá rovnoměrně rozdělit dokumenty mezi shardy a snižuje riziko, že by většina zápisů směřovala pouze na jeden shard.

Výsledek distribuce kolekce `events` je přibližně rovnoměrný:

| Shard | Počet dokumentů |
|---|---:|
| `shard01rs` | 43 364 |
| `shard02rs` | 42 589 |
| `shard03rs` | 43 105 |
| Celkem | 129 058 |

Kromě shardovacího klíče jsou vytvořeny také sekundární indexy:

| Index | Pole | Účel |
|---|---|---|
| `ix_events_match_id` | `match_id` | dotazy podle zápasu |
| `ix_events_player_id` | `player_id` | dotazy podle hráče |
| `ix_events_team_type` | `team_id`, `event_type_name` | dotazy podle týmu a typu události |
| `ix_events_season_minute` | `season`, `minute` | filtrování podle sezony a času zápasu |

Tyto indexy odpovídají používaným analytickým dotazům. Projekt často pracuje s filtrováním podle zápasu, hráče, týmu, typu události a minuty zápasu.

#### 1.2.5 Replikace

Replikace je použita na úrovni všech shardů a config serverů.

Každý shard má tři uzly:

- 1 primární uzel,
- 2 sekundární uzly.

Stejný princip je použit také u config serverů, které tvoří replica set `configReplSet`.

Replikační faktor tři je pro tento projekt dostačující. Pokud vypadne jeden uzel, replica set stále obsahuje většinu členů a může pokračovat v provozu. Pokud vypadne primární uzel, MongoDB automaticky zvolí nový primární uzel ze sekundárních členů.

Tato konfigurace umožňuje při obhajobě ukázat běžný scénář výpadku a obnovy uzlu.

#### 1.2.6 Perzistence dat

Perzistence dat je řešena pomocí Docker volumes.

Každý config server i každý shardový uzel má vlastní volume připojený do adresáře `/data/db`. Díky tomu data nezmizí při běžném restartu kontejneru.

MongoDB používá úložiště WiredTiger. Primární paměť je využívána hlavně pro cache často používaných dat a indexů. Sekundární paměť představují soubory uložené na disku v Docker volumes.

Data se do databáze načítají z připravených JSON souborů:

- `matches.json`,
- `players.json`,
- `events.json`.

Import probíhá automaticky při spuštění clusteru pomocí inicializační služby `cluster-setup`. Po importu jsou aplikována validační schémata a vytvořeny indexy.

Pokud se spustí `docker compose down`, kontejnery se zastaví, ale data ve volumes zůstávají. Pokud se spustí `docker compose down -v`, volumes se odstraní a celé prostředí lze znovu vytvořit automaticky od začátku.

#### 1.2.7 Distribuce dat

Distribuce dat probíhá přes `mongos` router.

Klient neposílá dotazy přímo na jednotlivé shardy. Připojuje se pouze na router `mongos-router`. Router podle metadat z config serverů rozhodne, na které shardy má dotaz poslat.

Zápisy do kolekce `events` jsou rozdělovány podle hashovaného shardovacího klíče `event_id`. MongoDB podle tohoto klíče určí, do kterého chunku dokument patří, a následně jej uloží na odpovídající shard.

Na každém shardu je zápis proveden na primárním uzlu a poté replikován na dva sekundární uzly.

Čtení a agregační dotazy také procházejí přes `mongos`. Pokud dotaz obsahuje shardovací klíč nebo jinou selektivní podmínku, může být směrován efektivněji. Pokud jde o širší analytický dotaz, `mongos` jej může rozeslat na více shardů a výsledky sloučit.

Distribuce kolekce `events` po importu ukazuje, že data jsou mezi shardy rozdělena rovnoměrně:

| Shard | Počet dokumentů | Přibližný podíl |
|---|---:|---:|
| `shard01rs` | 43 364 | 33,6 % |
| `shard02rs` | 42 589 | 33,0 % |
| `shard03rs` | 43 105 | 33,4 % |

Tento výsledek potvrzuje, že zvolený hashovaný shardovací klíč je pro kolekci `events` vhodný.

#### 1.2.8 Zabezpečení

Zabezpečení je řešeno na dvou úrovních.

První úroveň je interní autentizace mezi uzly MongoDB clusteru. K tomu se používá keyfile. Keyfile není uložen jako pevný veřejný soubor v repozitáři. Při spuštění jej vytvoří služba `keyfile-setup` a uloží jej do samostatného Docker volume.

Tento přístup splňuje požadavek zadání, že MongoDB má používat keyfile a že keyfile nemá být fixní veřejný soubor.

Druhá úroveň je autentizace a autorizace uživatelů.

Při inicializaci jsou vytvořeni uživatelé:

| Uživatel | Databáze | Role | Účel |
|---|---|---|---|
| `admin` | `admin` | `root` | administrace clusteru |
| `statsbomb_user` | `statsbomb` | `readWrite` | běžná práce s projektovou databází |

Autorizace je zapnuta v konfiguračních souborech MongoDB. Databáze tedy není přístupná anonymně a běžná práce s daty je oddělena od administrátorských oprávnění.

Zabezpečení je možné při obhajobě ověřit přihlášením přes `mongosh`, kontrolou uživatelů a kontrolou nastavení `keyFile` v konfiguraci MongoDB.

## 2 Funkční řešení

Tato kapitola popisuje praktickou část projektu. Funkční řešení je uloženo ve složce `Funkcni_reseni` a obsahuje vše potřebné pro spuštění MongoDB clusteru pomocí Docker Compose.

Cílem funkční části je, aby bylo možné celé prostředí spustit co nejvíce automatizovaně. Po spuštění Docker Compose se vytvoří keyfile, spustí se MongoDB kontejnery, inicializují se replica sety, přidají se shardy, vytvoří se uživatelé, importují se data a nastaví se validační schémata a indexy.

Základní spuštění řešení je:

```powershell
cd Funkcni_reseni
docker compose up -d
```

Po dokončení inicializace je cluster připravený k použití přes `mongos-router` na portu `27030`.

### 2.1 Struktura

Projekt je rozdělen do několika hlavních složek. Každá složka má v projektu konkrétní účel.

| Složka / soubor | Účel |
|---|---|
| `Data/processed` | připravené CSV a JSON soubory pro import do MongoDB |
| `Data/scripts` | Python skripty pro přípravu a analýzu dat |
| `Data/notebooks` | Jupyter notebook s analýzou dat |
| `Data/analysis` | vygenerované tabulky, statistiky a grafy |
| `Dotazy` | MongoDB dotazy a jejich výstupy |
| `Funkcni_reseni` | Docker Compose řešení MongoDB clusteru |
| `README.md` | základní popis projektu a spuštění |

Nejdůležitější složkou pro běh databáze je `Funkcni_reseni`.

Její struktura je následující:

| Soubor / složka | Popis |
|---|---|
| `docker-compose.yml` | definice všech kontejnerů MongoDB clusteru |
| `.env.example` | ukázka konfiguračních proměnných |
| `.env` | lokální hodnoty proměnných pro spuštění |
| `config/mongod-configsvr.conf` | konfigurace config serverů |
| `config/mongod-shard.conf` | konfigurace shard serverů |
| `config/mongos.conf` | konfigurace `mongos` routeru |
| `scripts/auto-setup.sh` | hlavní automatický inicializační skript |
| `scripts/import-data.ps1` | pomocný skript pro ruční reimport dat |
| `scripts/pre-defense-check.ps1` | ověřovací skript před obhajobou |
| `scripts/mongo/post-import-setup.js` | nastavení validačních schémat a indexů |
| `scripts/mongo/cluster-health.js` | skript pro kontrolu stavu clusteru |
| `evidence` | výstupy z kontrolních běhů a důkazy pro obhajobu |

Tato struktura umožňuje oddělit konfiguraci clusteru, inicializační skripty, data a kontrolní výstupy. Díky tomu je projekt přehlednější a při obhajobě lze snadno ukázat, kde se nachází konkrétní část řešení.

### 2.1.1 docker-compose.yml

Soubor `docker-compose.yml` je hlavní soubor pro spuštění celého MongoDB clusteru.

Používá oficiální Docker image:

```text
mongo:8.0.20
```

Verzi lze změnit pomocí proměnné `MONGO_IMAGE_TAG`, ale výchozí hodnota v projektu je `8.0.20`.

Soubor definuje tyto hlavní skupiny služeb:

| Skupina služeb | Kontejnery | Úloha |
|---|---|---|
| Keyfile setup | `mongo-keyfile-setup` | vytvoření interního keyfile |
| Config servery | `configsvr01`, `configsvr02`, `configsvr03` | metadata sharded clusteru |
| Shard 1 | `shard01a`, `shard01b`, `shard01c` | první shard replica set |
| Shard 2 | `shard02a`, `shard02b`, `shard02c` | druhý shard replica set |
| Shard 3 | `shard03a`, `shard03b`, `shard03c` | třetí shard replica set |
| Router | `mongos-router` | vstupní bod pro klienta |
| Inicializace | `mongo-cluster-setup` | automatické nastavení clusteru |

#### Porty

Veřejně vystavený je pouze router `mongos-router`.

| Služba | Interní port | Port na hostiteli | Účel |
|---|---:|---:|---|
| `mongos-router` | `27017` | `27030` | připojení klienta k MongoDB clusteru |

Ostatní MongoDB kontejnery komunikují uvnitř Docker sítě `mongo-cluster`. Není nutné se na ně připojovat přímo z hostitelského systému.

#### Volumes

Perzistence dat je řešena pomocí Docker volumes.

| Volume | Účel |
|---|---|
| `mongo_keyfile` | uložený keyfile pro interní autentizaci |
| `configsvr01_data`, `configsvr02_data`, `configsvr03_data` | data config serverů |
| `shard01a_data` až `shard03c_data` | data jednotlivých shardových uzlů |

Každý MongoDB uzel má vlastní volume připojený do `/data/db`. Díky tomu data přežijí restart kontejnerů.

#### Proměnné prostředí

Projekt používá několik proměnných prostředí. Výchozí hodnoty jsou uvedeny v `docker-compose.yml` a ukázka je také v souboru `.env.example`.

| Proměnná | Výchozí hodnota | Význam |
|---|---|---|
| `MONGO_IMAGE_TAG` | `8.0.20` | verze MongoDB image |
| `MONGOS_PORT` | `27030` | port pro připojení přes `mongos` |
| `MONGO_ROOT_USERNAME` | `admin` | administrátorský uživatel |
| `MONGO_ROOT_PASSWORD` | `admin123` | heslo administrátora |
| `MONGO_APP_DB` | `statsbomb` | název projektové databáze |
| `MONGO_APP_USERNAME` | `statsbomb_user` | aplikační uživatel |
| `MONGO_APP_PASSWORD` | `statsbomb_pass123` | heslo aplikačního uživatele |

Pro semestrální práci jsou tyto hodnoty dostačující. V produkčním prostředí by bylo nutné použít silnější hesla a řešit jejich bezpečné uložení mimo repozitář.

#### Závislosti služeb

Služba `mongos` závisí na config serverech a shardech. Spustí se až poté, co jsou definované MongoDB kontejnery vytvořeny.

Služba `cluster-setup` závisí na všech databázových kontejnerech a na `mongos`. Její úkolem je provést celé automatické nastavení clusteru.

Tento inicializační kontejner spouští skript:

```text
scripts/auto-setup.sh
```

Skript postupně provádí tyto kroky:

1. čeká, dokud nejsou MongoDB kontejnery dostupné,
2. inicializuje replica set `configReplSet`,
3. inicializuje replica sety `shard01rs`, `shard02rs` a `shard03rs`,
4. vytvoří administrátorského uživatele,
5. přidá shardy do clusteru,
6. vytvoří aplikačního uživatele,
7. připraví shardovanou kolekci `events`,
8. importuje data z `Data/processed`,
9. aplikuje validační schémata,
10. vytvoří indexy.

Díky tomu není nutné po spuštění ručně vstupovat do kontejnerů a spouštět jednotlivé příkazy.

#### Konfigurační soubory

MongoDB kontejnery používají konfigurační soubory ze složky `config`.

| Soubor | Použití |
|---|---|
| `mongod-configsvr.conf` | config servery, port `27017`, role `configsvr`, replica set `configReplSet` |
| `mongod-shard.conf` | shard servery, port `27018`, role `shardsvr` |
| `mongos.conf` | router `mongos`, napojení na `configReplSet` |

V konfiguraci je zapnuta interní autentizace pomocí `keyFile`. U config serverů a shard serverů je zapnuta také autorizace.

### 2.2 Instalace

Pro spuštění projektu je potřeba mít nainstalovaný Docker Desktop a Docker Compose. Na Windows musí být Docker Desktop spuštěný před startem projektu.

#### Postup spuštění

Nejprve je potřeba přejít do složky s funkčním řešením:

```powershell
cd Funkcni_reseni
```

Poté se spustí celý cluster:

```powershell
docker compose up -d
```

Tento příkaz spustí všechny kontejnery na pozadí. Po startu proběhne automatická inicializace pomocí služby `cluster-setup`.

Inicializace zahrnuje:

- vytvoření keyfile,
- spuštění config serverů,
- spuštění shardových replica setů,
- spuštění `mongos` routeru,
- vytvoření uživatelů,
- přidání shardů do clusteru,
- import dat,
- nastavení validačních schémat,
- vytvoření indexů.

#### Ověření běhu kontejnerů

Stav kontejnerů lze ověřit příkazem:

```powershell
docker compose ps
```

Kontejnery config serverů, shardů a routeru by měly být spuštěné. Kontejner `cluster-setup` je jednorázový, takže po dokončení inicializace může být ve stavu ukončeno.

#### Základní kontrola MongoDB

Základní dostupnost databáze lze ověřit příkazem:

```powershell
docker exec mongos-router mongosh --eval 'db.runCommand({ ping: 1 })'
```

Očekávaný výsledek obsahuje:

```text
ok: 1
```

Verzi MongoDB lze ověřit příkazem:

```powershell
docker exec mongos-router mongosh --eval 'db.runCommand({ buildInfo: 1 })'
```

Výstup má obsahovat verzi `8.0.20`.

#### Připojení s autentizací

Administrátorské připojení přes `mongos`:

```powershell
docker exec -it mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin
```

Po připojení lze přepnout na databázi:

```javascript
use statsbomb
```

Základní kontrola počtu dokumentů:

```javascript
db.events.countDocuments()
db.players.countDocuments()
db.matches.countDocuments()
```

Očekávané počty jsou:

| Kolekce | Počet dokumentů |
|---|---:|
| `events` | 129 058 |
| `players` | 476 |
| `matches` | 33 |

#### Kontrola shardingu

Stav shardingu lze ověřit příkazem:

```powershell
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'sh.status()'
```

Distribuci kolekce `events` lze ověřit také přes statistiky kolekce:

```powershell
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'db.getSiblingDB("statsbomb").events.stats()'
```

Výsledek má potvrdit, že kolekce `events` je shardovaná a že data jsou rozdělena mezi tři shardy.

#### Kontrola indexů

Indexy kolekce `events` lze zobrazit příkazem:

```powershell
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'db.getSiblingDB("statsbomb").events.getIndexes()'
```

Výstup má obsahovat shardovací index a sekundární indexy vytvořené pro analytické dotazy.

#### Automatická kontrola před obhajobou

Součástí projektu je skript:

```text
scripts/pre-defense-check.ps1
```

Spouští se ze složky `Funkcni_reseni`:

```powershell
.\scripts\pre-defense-check.ps1
```

Tento skript provede základní kontrolu clusteru a uloží důkazní výstupy do složky `Funkcni_reseni/evidence`.

Kontroluje například:

- běžící Docker kontejnery,
- dostupnost databáze,
- verzi MongoDB,
- počty dokumentů,
- statistiky databáze,
- statistiky kolekce `events`,
- indexy,
- uživatele,
- replica sety,
- informace o shardingu.

Pro ukázku výpadku uzlu lze spustit:

```powershell
.\scripts\pre-defense-check.ps1 -SimulateFailover -ReplicaSet shard01rs
```

Tento příkaz simuluje výpadek jednoho replica setu a uloží výsledky do složky `evidence`. Je vhodný jako podklad pro obhajobu, protože ukazuje, že cluster dokáže reagovat na výpadek uzlu.

#### Zastavení řešení

Cluster lze zastavit příkazem:

```powershell
docker compose down
```

Tento příkaz odstraní kontejnery, ale ponechá Docker volumes s daty.

Pokud je potřeba odstranit i data a vytvořit celý cluster znovu od začátku, použije se:

```powershell
docker compose down -v
```

Po tomto příkazu se při dalším `docker compose up -d` znovu vytvoří keyfile, databázové volumes, replica sety, shardy, uživatelé i import dat.

## 3 Případy užití a případové studie

MongoDB je dokumentová NoSQL databáze. Je vhodná zejména pro systémy, ve kterých se pracuje s daty ve formátu podobném JSON, s proměnlivou strukturou záznamů, s velkým objemem dokumentů a s požadavkem na horizontální škálování.

V této práci je MongoDB použita pro ukládání a analýzu fotbalových událostních dat. Data pochází ze StatsBomb Open Data a obsahují zápasy, hráče a jednotlivé herní události. Tento typ dat dobře odpovídá dokumentovému modelu, protože jedna událost může mít různé atributy podle typu akce. Například přihrávka obsahuje jiné doplňující informace než střela, faul nebo karta.

### 3.1 Pro jaké účely je MongoDB vhodná

MongoDB se hodí především pro aplikace, kde je výhodné ukládat data jako dokumenty a kde není nutné předem pevně definovat všechny sloupce jako v relační databázi.

Typické případy použití MongoDB jsou:

- ukládání polo-strukturovaných a hierarchických dat,
- webové a mobilní aplikace s rychlým vývojem datového modelu,
- content management systémy,
- produktové katalogy a e-commerce systémy,
- IoT a telemetrická data,
- analytické aplikace nad velkým množstvím událostí,
- systémy, kde je potřeba sharding a horizontální škálování,
- aplikace, které potřebují kombinovat rychlé dotazování, indexy a flexibilní strukturu dokumentů.

MongoDB ukládá data ve formátu BSON, který je binární reprezentací dokumentů podobných JSON. Dokument může obsahovat běžná pole, vnořené objekty i pole hodnot. Díky tomu je možné přirozeně modelovat objekty, které by v relační databázi často vyžadovaly více tabulek a spojení.

Výhodou MongoDB je také agregační framework. Pomocí pipeline operací jako `$match`, `$group`, `$lookup`, `$unwind`, `$project` nebo `$sort` lze provádět netriviální analytické dotazy přímo v databázi.

MongoDB je vhodná i pro distribuované nasazení. Pomocí replica setů zajišťuje replikaci a automatický failover. Pomocí shardingu umožňuje rozdělit velké kolekce mezi více shardů.

### 3.2 Účel mojí implementace a volba MongoDB

Účelem této implementace je vytvořit funkční MongoDB sharded cluster a ukázat, jak lze nad reálnými sportovními daty provádět analytické dotazování.

Projekt pracuje se třemi propojenými kolekcemi:

| Kolekce | Charakter dat | Role v projektu |
|---|---|---|
| `matches` | metadata zápasů | dimenzní kolekce |
| `players` | hráči a jejich týmy | dimenzní kolekce |
| `events` | jednotlivé herní události | hlavní faktová kolekce |

Největší kolekce `events` obsahuje 129 058 dokumentů. Každý dokument reprezentuje jednu událost v zápase. Události mohou být různých typů, například `Pass`, `Shot`, `Carry`, `Foul Committed` nebo `Ball Recovery`.

MongoDB byla zvolena z těchto důvodů:

- data mají událostní a dokumentový charakter,
- jednotlivé typy událostí nemají vždy stejná pole,
- největší kolekci lze shardovat podle `event_id`,
- nad daty lze provádět agregační dotazy přímo v databázi,
- kolekce lze propojovat pomocí `$lookup`,
- MongoDB podporuje indexy, validační schémata, autentizaci a replikaci,
- celé řešení lze dobře spustit v Docker Compose.

V projektu se MongoDB nepoužívá pouze jako jednoduché úložiště. Cluster je navržen tak, aby demonstroval distribuované zpracování dat. Kolekce `events` je shardována mezi tři shardy, každý shard je replica set se třemi uzly a data jsou dostupná přes `mongos` router.

Použitý datový model je pro MongoDB vhodný, protože hlavní kolekce `events` odpovídá událostnímu logu. Každý dokument popisuje jednu akci v zápase a obsahuje identifikátory pro spojení s kolekcemi `matches` a `players`.

Alternativní NoSQL databáze nebyly zvoleny z těchto důvodů:

| Technologie | Proč nebyla zvolena |
|---|---|
| Redis | je vhodný hlavně jako key-value úložiště a cache; pro analytické dotazy nad dokumenty a spojování dat by byl méně vhodný |
| Cassandra | je silná pro velké distribuované zápisy a předem známé dotazovací vzory, ale pro flexibilní agregační dotazy a `$lookup` není tak pohodlná |
| Elasticsearch / ELK | je výborný pro fulltextové vyhledávání a log analytics, ale cílem projektu je dokumentová databáze s replikací, shardingem a MongoDB agregačním frameworkem |
| Relační databáze | umožnila by práci s tabulkami a spojeními, ale méně přirozeně by ukládala proměnlivé atributy jednotlivých typů herních událostí |

MongoDB tak v tomto projektu představuje vhodný kompromis mezi flexibilním dokumentovým modelem, analytickým dotazováním a možností demonstrovat distribuovanou databázovou architekturu.

### 3.3 Tři případové studie pro MongoDB

Následující případové studie ukazují, že MongoDB se v praxi používá v různých typech systémů. Nejde pouze o akademickou databázi pro malé projekty, ale o technologii používanou pro mediální platformy, e-commerce systémy i IoT a big data.

#### 3.3.1 Forbes - modernizace CMS a cloudová migrace

Forbes je globální mediální společnost, která provozuje rozsáhlý digitální obsah a publikační platformu. Pro takový typ systému je důležitá rychlost vývoje, stabilita, škálovatelnost a možnost rychle přidávat nové funkce pro redaktory i čtenáře.

Původní technologické řešení Forbesu postupně přestávalo vyhovovat požadavkům na moderní digitální publikování. Mediální platforma potřebovala rychlejší vývoj, jednodušší údržbu a lepší podporu pro měnící se strukturu obsahu. V publikačním systému se často pracuje s články, autory, kategoriemi, tagy, multimediálními prvky, metadaty a personalizací. Taková data se mohou v čase měnit a ne vždy mají pevnou tabulkovou podobu.

MongoDB Atlas byl pro Forbes vhodný hlavně kvůli flexibilnímu dokumentovému modelu a jednodušší správě cloudové databáze. Dokumentový model umožňuje ukládat obsah a jeho metadata v přirozenější podobě než striktně relační model. Atlas zároveň snižuje potřebu ruční správy databázové infrastruktury, protože poskytuje řízenou cloudovou službu s nástroji pro provoz, zálohování a škálování.

Podle oficiální případové studie MongoDB přinesla migrace Forbesu na Google Cloud a MongoDB Atlas výrazné zrychlení vývoje. Forbes uvádí zkrácení průměrného build time z 25 minut na 9 minut, čtyřikrát rychlejší release cycle a snížení total cost of ownership o 25 %. Tyto výsledky ukazují, že výběr databáze neovlivňuje pouze samotné ukládání dat, ale také rychlost práce vývojového týmu a provozní náklady.

Z pohledu této semestrální práce je Forbes dobrým příkladem použití MongoDB pro obsahově bohatá a proměnlivá data. Podobnost s mým projektem spočívá v tom, že i fotbalová událostní data mají proměnlivou strukturu. Jiná pole jsou důležitá pro střelu, jiná pro přihrávku a jiná pro kartu. MongoDB umožňuje taková data ukládat jako dokumenty a nad nimi dále stavět dotazy.

Forbes zároveň ukazuje výhodu MongoDB při modernizaci existujícího systému. Databáze je vhodná tam, kde je potřeba rychle reagovat na nové požadavky, měnit datový model a zároveň zachovat výkon a provozní stabilitu.

Zdroj: https://www.mongodb.com/solutions/customer-case-studies/forbes

#### 3.3.2 eBay - mission-critical aplikace a více datových center

eBay je rozsáhlá globální e-commerce platforma. Pro takový systém je klíčová dostupnost, odolnost vůči výpadkům, rychlá odezva a schopnost obsluhovat velké množství uživatelů a dat. MongoDB zde není použita jako jednoduchá studentská databáze, ale jako součást enterprise architektury pro zákaznicky orientované aplikace.

Podle oficiálního MongoDB blogu eBay používá MongoDB jako jednu ze svých základních enterprise data platforem pro více zákaznicky orientovaných aplikací. Text zmiňuje globální rozsah eBay, velký počet aktivních kupujících, živých nabídek a trhů. V takovém prostředí není možné spoléhat na časté odstávky systému, protože dostupnost přímo ovlivňuje uživatele i obchodní procesy.

Zajímavým bodem této případové studie je důraz na multi-data center deployment. eBay řeší návrhové vzory pro odolné MongoDB aplikace a dostupnost při výpadcích. To odpovídá jednomu z hlavních důvodů, proč MongoDB používá replica sety. Pokud selže primární uzel, cluster může zvolit nový primární uzel a pokračovat v provozu.

MongoDB je pro eBay vhodná také díky horizontálnímu škálování. E-commerce systémy často pracují s katalogy, uživatelskými daty, metadaty, vyhledávacími nebo doporučovacími funkcemi. Některé části systému mohou mít dokumentový charakter a mohou se v čase měnit. MongoDB umožňuje tyto části modelovat flexibilněji než relační databáze s pevným schématem.

Pro můj projekt je tato případová studie důležitá hlavně kvůli architektuře. Také moje řešení není postavené jako jedna samostatná MongoDB instance, ale jako cluster se shardingem a replikací. Samozřejmě studentské řešení je výrazně menší než infrastruktura eBay, ale principy jsou podobné: data jsou rozdělena mezi shardy, každý shard je replikovaný a klient komunikuje přes router.

eBay ukazuje, že MongoDB se dá použít i pro kritické systémy, pokud je správně navržena topologie, replikace, monitoring a způsob práce s výpadky. To podporuje i část mé práce zaměřenou na simulaci failoveru a kontrolu replica setů.

Zdroj: https://www.mongodb.com/blog/post/ebay-building-mission-critical-multi-data-center-applications-with-mongodb

#### 3.3.3 Bosch Digital - IoT, big data a aplikační analytika

Bosch Digital používá MongoDB v oblasti IoT a big data. IoT systémy často generují velké množství dat z různých zařízení, senzorů a aplikací. Taková data mohou mít vysoký objem, různou strukturu a mohou být potřebná pro analýzu v téměř reálném čase.

Oficiální případová studie MongoDB popisuje Bosch Digital jako příklad organizace, která využívá MongoDB pro práci s velkými daty a získávání použitelných poznatků. V oblasti IoT je běžné, že data přicházejí průběžně z mnoha zdrojů. Databáze proto musí zvládat nejen ukládání dat, ale také jejich vyhledávání, filtrování, agregaci a další zpracování.

MongoDB je pro IoT vhodná kvůli flexibilnímu dokumentovému modelu. Různá zařízení mohou posílat různá pole a metadata. Pokud by se používala přísně relační struktura, každá změna struktury dat by mohla vyžadovat úpravy schématu. V MongoDB lze různé typy dokumentů ukládat v jedné kolekci nebo je rozdělit do kolekcí podle účelu aplikace.

Dalším důvodem je škálování. IoT data mohou růst velmi rychle. MongoDB sharding umožňuje rozdělit velkou kolekci mezi více shardů. Tím se databáze může přizpůsobit rostoucímu objemu dat. Replikace zároveň pomáhá zvýšit dostupnost a chránit data při výpadku uzlu.

Vztah k mému projektu je zde velmi přímý. Fotbalová událostní data nejsou IoT data, ale mají podobný analytický charakter. V obou případech jde o velké množství událostí, které mají časový nebo sekvenční kontext a různé atributy podle typu události. V mém projektu jsou to například minuty zápasu, týmy, hráči a typy herních akcí. V IoT by to mohly být časy měření, zařízení, senzory a typy naměřených hodnot.

Bosch Digital tak ukazuje, že MongoDB je vhodná pro událostní a analytická data, kde je důležité ukládat velký objem dokumentů, pracovat s proměnlivou strukturou a získávat z dat praktické výstupy.

Zdroj: https://www.mongodb.com/solutions/customer-case-studies/bosch

### 3.4 Shrnutí případů užití

Z uvedených případových studií vyplývá, že MongoDB se používá v různých prostředích:

| Organizace | Oblast | Hlavní důvod použití MongoDB |
|---|---|---|
| Forbes | média a CMS | flexibilní obsahový model, rychlejší vývoj, cloudová správa |
| eBay | e-commerce | dostupnost, odolnost, enterprise provoz ve velkém měřítku |
| Bosch Digital | IoT a big data | práce s velkým objemem událostních a proměnlivých dat |

Moje semestrální práce je menší než uvedené produkční systémy, ale používá stejné základní principy. MongoDB zde slouží jako dokumentová databáze pro událostní data, používá sharding pro rozdělení největší kolekce, replikaci pro dostupnost a agregační framework pro analytické dotazy.

Proto je MongoDB pro zvolený projekt vhodná. Umožňuje prakticky ukázat nejen práci s dokumenty, ale také důležité vlastnosti distribuované databáze.

## 4 Výhody a nevýhody

Tato kapitola hodnotí výhody a nevýhody MongoDB jako databázové technologie a následně také výhody a nevýhody konkrétního řešení vytvořeného v rámci této semestrální práce.

MongoDB je vhodná pro mnoho moderních aplikací, ale není univerzálně nejlepší volbou pro každý typ úlohy. Při návrhu databázového systému je nutné zohlednit typ dat, očekávané dotazy, požadavky na konzistenci, dostupnost, škálování a provozní složitost.

### 4.1 Výhody MongoDB

MongoDB má několik důležitých výhod, které jsou relevantní i pro tento projekt.

| Výhoda | Popis |
|---|---|
| Dokumentový model | Data jsou ukládána jako dokumenty podobné JSON/BSON, což je vhodné pro hierarchická a proměnlivá data. |
| Flexibilní schéma | Není nutné mít předem pevně definované všechny sloupce jako v relační databázi. |
| Agregační framework | MongoDB umožňuje provádět pokročilé analytické dotazy přímo v databázi. |
| Sharding | Velké kolekce lze horizontálně rozdělit mezi více shardů. |
| Replikace | Replica sety umožňují uchovávat kopie dat a provádět automatický failover. |
| Indexy | MongoDB podporuje primární, sekundární, složené, hashované a další typy indexů. |
| Docker podpora | MongoDB lze dobře provozovat v kontejnerech, což zjednodušuje reprodukovatelnost projektu. |
| Práce s JSON/CSV | Data lze relativně jednoduše importovat pomocí nástrojů jako `mongoimport`. |

Pro tuto semestrální práci je nejdůležitější kombinace dokumentového modelu, shardingu, replikace a agregačního frameworku.

Dokumentový model je vhodný pro StatsBomb data, protože jednotlivé fotbalové události nemají vždy stejnou strukturu. Například střela může obsahovat výsledek zakončení, přihrávka může obsahovat příjemce a karta může obsahovat typ karetního trestu. V MongoDB lze takové záznamy ukládat přirozeněji než v jedné pevné relační tabulce.

Agregační framework je výhodný pro analytické dotazy. V projektu jsou použity dotazy, které kombinují filtrování, seskupování, řazení, spojování kolekcí přes `$lookup`, práci s vnořenými strukturami a administrativní dotazy nad clusterem.

Sharding je důležitý pro ukázku horizontálního škálování. Kolekce `events` je rozdělena mezi tři shardy pomocí hashovaného shardovacího klíče `event_id`. Díky tomu lze prakticky demonstrovat distribuci dat mezi více uzlů.

Replikace je důležitá pro dostupnost a odolnost vůči výpadku. Každý shard v projektu obsahuje tři uzly, takže lze při obhajobě ukázat stav replica setů a případně simulovat výpadek jednoho uzlu.

### 4.2 Nevýhody MongoDB

MongoDB má také nevýhody a omezení. Tyto nevýhody je nutné znát, protože špatný návrh datového modelu, indexů nebo shardovacího klíče může vést k horšímu výkonu a složitější správě.

| Nevýhoda | Popis |
|---|---|
| Náročnější návrh shardovacího klíče | Špatně zvolený shardovací klíč může vést k nerovnoměrné distribuci dat nebo hot spotům. |
| Vyšší provozní složitost clusteru | Sharded cluster je složitější než jedna databázová instance. |
| Nutnost správného indexování | Bez vhodných indexů mohou dotazy procházet mnoho dokumentů a být pomalé. |
| Větší nároky na disk a paměť | Replikace, indexy a metadata zvyšují spotřebu úložiště. |
| Omezenější relační vazby | MongoDB podporuje `$lookup`, ale není to plná náhrada relačního modelu pro všechny typy vztahů. |
| Konzistence závisí na nastavení | Je nutné rozumět `writeConcern`, `readConcern` a chování replica setů při výpadku. |
| Složitější ladění výkonu | U distribuované databáze je potřeba sledovat indexy, shardy, chunky, síť a replikační stav. |

Největším rizikem u MongoDB je špatný návrh datového modelu. Pokud jsou data uložena nevhodně, mohou být dotazy složité nebo neefektivní. U rozsáhlejších systémů je také nutné dobře promyslet, která data budou embedded a která budou v samostatných kolekcích.

Dalším rizikem je shardovací klíč. Pokud má shardovací klíč nízkou kardinalitu nebo způsobuje nerovnoměrné rozdělení zápisů, může jeden shard nést větší zátěž než ostatní. V tomto projektu je proto pro kolekci `events` použit hashovaný klíč `event_id`, který je vhodný pro rovnoměrné rozdělení dokumentů.

MongoDB také vyžaduje správné indexování. Agregační dotazy nad velkou kolekcí bez indexů mohou být pomalé. V projektu jsou proto vytvořeny indexy podle reálných dotazovacích vzorů, například podle `match_id`, `player_id`, kombinace `team_id` a `event_type_name` nebo podle `season` a `minute`.

### 4.3 Výhody mého řešení

Konkrétní řešení v této práci má několik silných stránek. Nejde pouze o jednu samostatnou MongoDB instanci, ale o kompletní sharded cluster s automatizovaným nasazením.

| Výhoda řešení | Popis |
|---|---|
| Plně kontejnerizované řešení | Celý cluster je definován v Docker Compose. |
| Automatizované spuštění | Inicializace replica setů, shardů, uživatelů, importu dat, validátorů a indexů probíhá automaticky. |
| Aktuální verze MongoDB | Projekt používá MongoDB `8.0.20`. |
| Splnění požadavku na sharding | Kolekce `events` je rozdělena mezi tři shardy. |
| Splnění požadavku na replikaci | Každý shard má tři uzly. |
| Bezpečnostní konfigurace | Je použita autentizace, autorizace a generovaný keyFile. |
| Reálná data | Projekt pracuje s veřejnými StatsBomb fotbalovými daty. |
| Dostatečný objem dat | Kolekce `events` obsahuje 129 058 dokumentů, tedy výrazně více než požadovaných 5 000 záznamů. |
| Validační schémata | Kolekce mají nastavené MongoDB JSON Schema validátory. |
| Dotazy a výstupy | Projekt obsahuje 30 netriviálních dotazů a zachycené výstupy. |
| Kontrola před obhajobou | Skript `pre-defense-check.ps1` ukládá důkazní výstupy do složky `evidence`. |

Největší výhodou řešení je vysoká míra automatizace. Po spuštění příkazu `docker compose up -d` se prostředí nastaví bez nutnosti ručně spouštět jednotlivé příkazy uvnitř kontejnerů. To je důležité pro reprodukovatelnost a pro obhajobu, protože celý projekt lze znovu spustit na jiném zařízení.

Další výhodou je reálný charakter dat. StatsBomb Open Data nejsou uměle vytvořená testovací data, ale skutečná sportovní data. To umožňuje vytvářet smysluplné analytické dotazy, například hledání nejaktivnějších hráčů, počítání střel, analýzu přihrávek nebo porovnání týmů.

Silnou stránkou je také to, že řešení obsahuje validační schémata a indexy. Validátory omezují riziko vložení dokumentů s nesprávnou strukturou a indexy podporují typické dotazy nad kolekcí `events`.

Výhodou pro obhajobu je složka `evidence`. Ověřovací skript ukládá výstupy jako počty dokumentů, verzi MongoDB, statistiky databáze, informace o shardingu, indexy a stavy replica setů. Díky tomu lze doložit, že popsaná architektura odpovídá skutečně běžícímu řešení.

### 4.4 Nevýhody mého řešení

I když řešení splňuje hlavní požadavky zadání, má také několik omezení. Některá omezení jsou záměrná, protože projekt je semestrální práce a není navržen jako produkční systém.

| Nevýhoda řešení | Popis |
|---|---|
| Pouze jeden `mongos` router | V produkčním prostředí by bylo vhodné mít více routerů kvůli vyšší dostupnosti. |
| Běh na jednom fyzickém zařízení | Všechny kontejnery běží lokálně, takže nejde o skutečně geograficky distribuovaný cluster. |
| Jednoduchá hesla v ukázkové konfiguraci | Pro semestrální práci jsou dostačující, ale v produkci by bylo nutné použít bezpečnější správu tajemství. |
| Omezené výkonnostní testování | Projekt se zaměřuje hlavně na funkčnost, architekturu a dotazy, ne na rozsáhlé benchmarky. |
| Shardována je pouze největší kolekce | `matches` a `players` nejsou shardované, protože jsou malé. |
| Data jsou dávkově importovaná | Projekt neřeší živé streamování nových událostí. |
| Chybí aplikační rozhraní | Nad databází není vytvořena webová aplikace ani dashboard. |

Použití jednoho `mongos` routeru je největší zjednodušení oproti produkčnímu nasazení. Pro účely semestrální práce je jeden router dostačující, protože umožňuje ukázat směrování dotazů přes `mongos`. V produkčním systému by ale bylo vhodné mít více routerů a případně load balancer.

Dalším omezením je, že všechny kontejnery běží na jednom zařízení. To znamená, že projekt demonstruje logickou distribuovanou architekturu, ale neřeší skutečné fyzické oddělení serverů, síťovou latenci nebo výpadek celého stroje.

Projekt také neobsahuje pokročilé výkonnostní benchmarky. Jsou zde dotazy s `explain`, indexy a administrativní kontroly, ale cílem práce není detailní porovnání výkonu s jinými databázemi nebo měření při velké zátěži.

Menší kolekce `matches` a `players` nejsou shardované. Toto rozhodnutí je záměrné, protože mají pouze desítky až stovky dokumentů. Shardování tak malých kolekcí by v tomto projektu nepřineslo praktickou výhodu a zbytečně by komplikovalo řešení.

### 4.5 Shrnutí výhod a nevýhod

MongoDB je pro tento projekt vhodná, protože dobře pracuje s dokumentovými a událostními daty, podporuje sharding, replikaci, indexy a agregační dotazy.

Hlavní výhody projektu jsou:

- plně automatizované spuštění přes Docker Compose,
- sharded cluster se třemi shardy,
- tři uzly v každém shardu,
- generovaný keyFile,
- autentizace a autorizace,
- reálná propojená data,
- více než 129 tisíc dokumentů v hlavní kolekci,
- validační schémata,
- indexy,
- 30 netriviálních dotazů,
- ověřovací skript pro obhajobu.

Hlavní nevýhody projektu jsou:

- jeden `mongos` router,
- lokální běh všech kontejnerů na jednom zařízení,
- absence webové aplikace,
- omezené výkonnostní testování,
- dávkový import místo živého datového toku.

Celkově řešení odpovídá účelu semestrální práce. Není navrženo jako produkční systém, ale dobře demonstruje principy MongoDB clusteru, práci s reálnými daty, sharding, replikaci, zabezpečení a analytické dotazování.

## 5 Další specifika

Implementace MongoDB je provedena převážně podle doporučeného modelu pro sharded cluster. Řešení obsahuje standardní komponenty MongoDB, tedy tři config servery, tři shardové replica sety, jeden `mongos` router, replikaci, sharding, indexaci, autentizaci, autorizaci a validační schémata. Nebyly použity žádné vlastní úpravy MongoDB, patche ani nestandardní rozšíření databázového systému. Jediným výraznějším specifikem projektu je automatizované spuštění pomocí Docker Compose, kdy inicializační skripty samy vytvoří replica sety, přidají shardy, vytvoří uživatele, importují data, nastaví validaci a indexy. Toto specifikum ale nemění chování MongoDB, pouze zjednodušuje opakovatelné spuštění a obhajobu řešení. Celkově tedy projekt odpovídá běžnému doporučenému nasazení MongoDB pro demonstrační sharded cluster a neobsahuje nadbytečné nebo nestandardní komponenty.

## 6 Data

Tato kapitola popisuje zdrojová data, jejich předzpracování, výslednou strukturu datových souborů a základní analýzu kvality dat. Cílem datové části je doložit, že projekt pracuje se třemi vzájemně propojitelnými datovými soubory, že jeden z nich výrazně překračuje požadovaný limit 5 000 záznamů a že zvolená struktura je vhodná pro dokumentovou databázi MongoDB.

### 6.1 Zdroj a charakter dat

Jako datový zdroj byla zvolena veřejná datová sada StatsBomb Open Data. StatsBomb poskytuje fotbalová data ve formátu JSON. Tato data obsahují informace o soutěžích, sezonách, zápasech, sestavách hráčů a jednotlivých událostech v zápasech.

V projektu je použita soutěž La Liga a sezona 2019/2020. Tato kombinace byla zvolena proto, že obsahuje reálná sportovní data, dostatečný počet událostí a zároveň přirozené vazby mezi zápasy, hráči a herními událostmi.

Zdroj dat:

```text
https://github.com/statsbomb/open-data
```

Původní surová data byla lokálně uložena ve složce `Data/raw`. Tato složka ale není součástí odevzdávaného projektu ani verzovaného repozitáře, protože obsahuje velmi velký objem původních souborů. Celý zdrojový archiv obsahoval přibližně stovky milionů řádků nebo záznamů, řádově až kolem 600 milionů, a jeho vložení do projektu by neúměrně zvětšilo výsledný ZIP soubor. Z tohoto důvodu bylo rozhodnuto ponechat v projektu pouze připravené, vyfiltrované a analyzované výstupy ve složkách `Data/processed` a `Data/analysis`.

Toto rozhodnutí nemění reprodukovatelnost řešení. Původní data jsou veřejně dostupná ze zdrojového repozitáře StatsBomb Open Data a proces transformace je popsán a implementován ve skriptu:

```text
Data/scripts/prepare_statsbomb_data.py
```

### 6.2 Použité datové soubory

Pro MongoDB jsou připraveny tři propojené datové sady. Každá datová sada je uložena ve formátu CSV i JSON. Do MongoDB se importují JSON soubory, protože dokumentová databáze přirozeně pracuje s dokumenty podobnými JSON/BSON.

| Kolekce | Soubor CSV | Soubor JSON | Počet záznamů | Počet sloupců | Úloha v projektu |
|---|---|---|---:|---:|---|
| `matches` | `matches.csv` | `matches.json` | 33 | 18 | metadata zápasů |
| `players` | `players.csv` | `players.json` | 476 | 9 | metadata hráčů |
| `events` | `events.csv` | `events.json` | 129 058 | 28 | hlavní faktová kolekce událostí |

Největší datovou sadou je `events`, která obsahuje 129 058 záznamů. Tato kolekce splňuje požadavek zadání na alespoň 5 000 záznamů v jednom datovém souboru. Zároveň je to hlavní kolekce, nad kterou jsou prováděny analytické dotazy a která je v MongoDB shardována.

Vztahy mezi datovými soubory jsou následující:

| Vazba | Popis |
|---|---|
| `events.match_id` -> `matches.match_id` | každá událost patří ke konkrétnímu zápasu |
| `events.player_id` -> `players.player_id` | událost může být přiřazena konkrétnímu hráči |
| `events.team_id` a `players.team_id` | umožňuje analyzovat hráče a události podle týmů |
| `matches.home_team_id`, `matches.away_team_id` -> `events.team_id` | umožňuje rozlišovat domácí a hostující tým v dotazech |

Díky těmto vazbám lze v MongoDB používat `$lookup` dotazy mezi kolekcemi. Projekt tedy nepracuje se třemi izolovanými tabulkami, ale s propojeným datovým modelem.

### 6.3 Typy dat a formát

Původní data StatsBomb jsou ve formátu JSON. Při předzpracování byla převedena do kompaktních CSV a JSON souborů. CSV soubory slouží hlavně pro kontrolu, Python analýzu a čitelné zobrazení dat. JSON soubory jsou používány pro import do MongoDB pomocí nástroje `mongoimport`.

MongoDB ukládá data jako BSON dokumenty. To je pro tento projekt vhodné, protože fotbalová událostní data mají částečně proměnlivou strukturu. Například střela obsahuje jiné atributy než přihrávka, karta nebo držení míče. V relační databázi by bylo nutné buď vytvářet mnoho tabulek, nebo ukládat velké množství prázdných sloupců. V MongoDB lze tyto záznamy uložit přirozeněji jako dokumenty s volitelnými poli.

Hlavní typy dat v projektu:

| Typ dat | Příklady polí | Použití |
|---|---|---|
| Identifikátory | `match_id`, `player_id`, `team_id`, `event_id` | propojení kolekcí a shardovací klíč |
| Textová data | `player_name`, `team_name`, `event_type_name` | čitelné popisy a filtrování |
| Časová data | `match_date`, `timestamp`, `minute`, `second` | analýza průběhu zápasu |
| Číselná data | `home_score`, `away_score`, `location_x`, `location_y`, `duration` | statistiky, agregace a výpočty |
| Kategorická data | `shot_outcome_name`, `card_name`, `position_name` | rozdělení událostí podle typu |

### 6.4 Rozsah a kvalita dat

Základní přehled výsledných datových souborů byl vytvořen pomocí Python skriptu:

```text
Data/scripts/analyze_statsbomb_data.py
```

Výstupy analýzy jsou uloženy ve složce:

```text
Data/analysis
```

Souhrnná tabulka ukazuje počet řádků, počet sloupců, počet chybějících hodnot a počet duplicitních řádků:

| Dataset | Počet řádků | Počet sloupců | Chybějící hodnoty celkem | Duplicitní řádky |
|---|---:|---:|---:|---:|
| `events` | 129 058 | 28 | 482 946 | 0 |
| `players` | 476 | 9 | 186 | 0 |
| `matches` | 33 | 18 | 52 | 0 |

V datech nejsou duplicitní řádky. Chybějící hodnoty se vyskytují hlavně u polí, která nejsou relevantní pro všechny typy událostí. To je u StatsBomb dat očekávané a neznamená to chybu datové sady.

Největší počet chybějících hodnot je v kolekci `events`:

| Sloupec | Počet chybějících hodnot | Podíl | Vysvětlení |
|---|---:|---:|---|
| `card_name` | 129 022 | 99,97 % | většina událostí není karta |
| `shot_outcome_name` | 128 306 | 99,42 % | pouze střely mají výsledek střely |
| `pass_recipient_id` | 93 338 | 72,32 % | pouze přihrávky mají příjemce |
| `pass_recipient_name` | 93 338 | 72,32 % | textová verze příjemce přihrávky |
| `duration` | 35 718 | 27,68 % | ne každá událost má délku trvání |

U kolekce `matches` chybí hlavně údaje o rozhodčím. Konkrétně pole `referee_id` a `referee_name` chybí u 26 z 33 zápasů. Tyto hodnoty nejsou pro hlavní databázovou funkcionalitu kritické, protože dotazy pracují hlavně se zápasy, týmy, hráči a událostmi.

U kolekce `players` chybí nejčastěji pole `position` a `player_nickname`. Tyto hodnoty jsou doplňkové. Povinné identifikační a vazební atributy jako `player_id`, `player_name`, `team_id`, `team_name` a `season` jsou dostupné.

### 6.5 Předzpracování a transformace dat

Předzpracování dat probíhá ve skriptu `Data/scripts/prepare_statsbomb_data.py`. Skript načítá původní JSON soubory ze StatsBomb Open Data, vybere soutěž La Liga a sezonu 2019/2020 a vytvoří tři kompaktní datové sady.

Hlavní kroky transformace:

1. načtení souboru `competitions.json`,
2. vyhledání soutěže La Liga a sezony 2019/2020,
3. načtení zápasů pro vybranou sezonu,
4. vytvoření datové sady `matches`,
5. načtení sestav a vytvoření datové sady `players`,
6. načtení událostí jednotlivých zápasů a vytvoření datové sady `events`,
7. výběr důležitých polí pro MongoDB,
8. sjednocení názvů polí,
9. uložení výsledků do CSV a JSON.

Při transformaci nebyla data uměle generována. Projekt pracuje s reálnými sportovními daty. Úpravy měly hlavně technický a strukturální charakter, aby data byla vhodná pro databázový projekt a aby se s nimi dalo dobře pracovat při dotazování.

Příklad vybraných polí v kolekci `matches`:

| Pole | Význam |
|---|---|
| `match_id` | identifikátor zápasu |
| `match_date` | datum zápasu |
| `season` | sezona |
| `home_team_id`, `home_team_name` | domácí tým |
| `away_team_id`, `away_team_name` | hostující tým |
| `home_score`, `away_score` | skóre zápasu |
| `stadium_name` | stadion |
| `referee_name` | rozhodčí, pokud je uveden |

Příklad vybraných polí v kolekci `players`:

| Pole | Význam |
|---|---|
| `player_id` | identifikátor hráče |
| `player_name` | jméno hráče |
| `jersey_number` | číslo dresu |
| `country` | země hráče |
| `team_id`, `team_name` | tým hráče |
| `position` | pozice hráče, pokud je dostupná |

Příklad vybraných polí v kolekci `events`:

| Pole | Význam |
|---|---|
| `event_id` | unikátní identifikátor události |
| `match_id` | vazba na zápas |
| `minute`, `second` | čas události v zápase |
| `team_id`, `team_name` | tým spojený s událostí |
| `player_id`, `player_name` | hráč spojený s událostí |
| `event_type_name` | typ události, například Pass, Shot nebo Carry |
| `location_x`, `location_y` | pozice události na hřišti |
| `shot_outcome_name` | výsledek střely |
| `card_name` | typ karty |

### 6.6 Proč nebyla použita jiná datová struktura

Pro tento projekt nebylo vhodné uložit všechna data do jedné velké kolekce. Jedna kolekce by sice zjednodušila import, ale vedla by k velké redundanci. Údaje o zápasech a hráčích by se opakovaly u mnoha událostí. Proto byly zvoleny tři kolekce, které jsou propojené přes identifikátory.

Zároveň nebylo vhodné data příliš normalizovat do mnoha malých kolekcí. MongoDB je dokumentová databáze a projekt má ukázat práci s dokumenty, agregacemi, vnořenými výstupy a `$lookup`. Tři hlavní kolekce představují kompromis mezi čitelností, propojením dat a jednoduchostí obhajoby.

Zvolený model odpovídá analytickému charakteru dat:

- `events` funguje jako hlavní faktová kolekce,
- `matches` obsahuje metadata zápasů,
- `players` obsahuje metadata hráčů.

Tento model umožňuje jak jednoduché filtrování jedné kolekce, tak složitější analytické dotazy s propojením více kolekcí.

### 6.7 Analýza dat v Pythonu

Analýza dat byla provedena pomocí Pythonu a knihoven `pandas`, `matplotlib` a `seaborn`. Skript `Data/scripts/analyze_statsbomb_data.py` vytváří souhrnné tabulky, statistiky chybějících hodnot, numerické statistiky a grafické výstupy.

Vygenerované soubory:

| Soubor | Účel |
|---|---|
| `dataset_overview.csv` | počet řádků, sloupců, chybějících hodnot a duplicit |
| `all_missing_summary.csv` | přehled chybějících hodnot napříč všemi datasety |
| `all_numeric_summary.csv` | numerické statistiky pro číselné sloupce |
| `data_analysis_report.md` | textový report s výsledky analýzy |
| `plots/*.png` | grafické výstupy použitelné v dokumentaci |

Numerická analýza ukazuje například průběh minut v zápasech, rozsah identifikátorů, skóre zápasů, počet událostí a další číselné charakteristiky. U kolekce `events` je důležité hlavně to, že obsahuje dostatečně velký počet záznamů pro demonstraci shardingu, indexů a agregačních dotazů.

### 6.8 Grafické výstupy a interpretace

Pro lepší pochopení dat byly vytvořeny grafické výstupy. Grafy nejsou pouze dekorací, ale pomáhají vysvětlit velikost dat, kvalitu dat a rozložení hlavních fotbalových událostí.

Vložit graf: `dataset_sizes.png`

Graf `dataset_sizes.png` porovnává velikosti tří výsledných datových sad. Je z něj vidět, že kolekce `events` je výrazně větší než `matches` a `players`. To potvrzuje, že `events` je hlavní faktová kolekce a že je vhodným kandidátem pro sharding.

Vložit graf: `top_missing_columns.png`

Graf `top_missing_columns.png` zobrazuje sloupce s nejvyšším počtem chybějících hodnot. Nejvýraznější jsou atributy specifické pro konkrétní typ události, například `card_name`, `shot_outcome_name` a `pass_recipient_id`. Tyto chybějící hodnoty jsou očekávané, protože ne každá událost je střela, karta nebo přihrávka.

Vložit graf: `top_event_types.png`

Graf `top_event_types.png` ukazuje nejčastější typy událostí v kolekci `events`. Nejvíce se vyskytují události jako `Pass`, `Ball Receipt*`, `Carry` a `Pressure`. To odpovídá charakteru fotbalových event dat, kde většinu zápasu tvoří přihrávky, převzetí míče, pohyby hráčů a presink.

Vložit graf: `event_minutes_histogram.png`

Histogram `event_minutes_histogram.png` ukazuje rozložení událostí podle minuty zápasu. Pomáhá ověřit, že data pokrývají celý průběh utkání a nejsou soustředěna jen do malé části zápasu.

Vložit graf: `shot_outcomes.png`

Graf `shot_outcomes.png` zobrazuje rozdělení výsledků střel. Nejčastější výsledky jsou střely mimo branku, uložené střely, blokované střely a góly. Tento graf je vhodný pro vysvětlení analytického potenciálu dat, protože ukazuje, že nad událostmi lze počítat sportovní metriky.

Vložit graf: `top_teams_by_shots.png`

Graf `top_teams_by_shots.png` porovnává týmy podle počtu střel. Barcelona má v datech výrazně vyšší počet střel, protože vybraná datová sada je soustředěna na zápasy Barcelony v sezoně La Liga 2019/2020. Tuto skutečnost je důležité při interpretaci výsledků zmínit, aby nebyly závěry prezentovány jako statistika celé soutěže.

Vložit graf: `player_countries.png`

Graf `player_countries.png` ukazuje nejčastější země hráčů v kolekci `players`. Tento graf doplňuje popis datové sady o demografický pohled na hráče.

### 6.9 Shrnutí datové části

Datová část projektu splňuje požadavky zadání. Projekt obsahuje tři propojené datové soubory, z nichž jeden obsahuje výrazně více než 5 000 záznamů. Data pocházejí z veřejného zdroje StatsBomb Open Data a byla zpracována pomocí Python skriptů.

Výsledný datový model je vhodný pro MongoDB, protože kombinuje dokumentový charakter událostí, propojení mezi kolekcemi a možnost analytického dotazování. Kolekce `events` je dostatečně velká pro demonstraci shardingu, zatímco kolekce `matches` a `players` poskytují kontext pro `$lookup` dotazy.

Surová složka `Data/raw` není přiložena do odevzdávaného projektu z důvodu extrémní velikosti původních dat. Místo toho projekt obsahuje připravené datové výstupy, skripty pro transformaci, skripty pro analýzu a výsledné grafy. Tento přístup udržuje projekt spustitelný a přehledný, ale zároveň zachovává možnost opětovného vytvoření dat z veřejného zdroje.

## 7 Dotazy

Tato kapitola uvádí vybrané reprezentativní MongoDB dotazy nad databází `statsbomb`. Celkem bylo pro projekt připraveno 30 netriviálních dotazů rozdělených do pěti kategorií. V hlavním textu dokumentace je z každé kategorie uveden jeden ukázkový dotaz, aby bylo zřejmé, jakým způsobem jsou data dotazována a jaké části MongoDB jsou využity.

Úplný seznam všech 30 dotazů je uložen ve složce:

```text
Dotazy/mongo_queries.md
```

Zachycené výstupy dotazů jsou uloženy v souboru:

```text
Dotazy/mongo_query_outputs.md
```

### 7.1 Kategorie 1 - Join / lookup

#### Dotaz: Nejčastější dvojice přihrávající hráč - příjemce

Cílem dotazu je najít nejčastější přihrávkové dvojice a obohatit výsledek o jména hráčů z kolekce `players`.

```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Pass",
      player_id: { $ne: null },
      pass_recipient_id: { $ne: null }
    }
  },
  {
    $group: {
      _id: {
        passer_id: "$player_id",
        recipient_id: "$pass_recipient_id"
      },
      successful_passes: { $sum: 1 }
    }
  },
  { $sort: { successful_passes: -1, "_id.passer_id": 1, "_id.recipient_id": 1 } },
  { $limit: 10 },
  {
    $lookup: {
      from: "players",
      localField: "_id.passer_id",
      foreignField: "player_id",
      as: "passer"
    }
  },
  {
    $lookup: {
      from: "players",
      localField: "_id.recipient_id",
      foreignField: "player_id",
      as: "recipient"
    }
  },
  { $unwind: "$passer" },
  { $unwind: "$recipient" },
  {
    $project: {
      _id: 0,
      passer_name: "$passer.player_name",
      recipient_name: "$recipient.player_name",
      passer_team: "$passer.team_name",
      recipient_team: "$recipient.team_name",
      successful_passes: 1
    }
  }
])
```

Obecně tento dotaz ukazuje použití agregace, seskupení, řazení a dvou operací `$lookup`. Nejprve se vyfiltrují pouze přihrávky, potom se vytvoří dvojice hráčů podle identifikátorů a následně se pomocí kolekce `players` převedou identifikátory na čitelná jména. V konkrétním projektu tento dotaz ukazuje nejčastější passing links v zápasech La Ligy 2019/2020.

### 7.2 Kategorie 2 - Agregační funkce a statistiky

#### Dotaz: Týmy s nejlepší střeleckou konverzí

Cílem dotazu je spočítat u týmů s alespoň 10 střelami, kolik střel skončilo gólem a jaká je procentuální úspěšnost zakončení.

```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { event_type_name: "Shot", team_name: { $ne: null } } },
  {
    $group: {
      _id: "$team_name",
      total_shots: { $sum: 1 },
      goals_scored: {
        $sum: {
          $cond: [
            { $eq: ["$shot_outcome_name", "Goal"] },
            1,
            0
          ]
        }
      }
    }
  },
  { $match: { total_shots: { $gte: 10 } } },
  {
    $project: {
      _id: 0,
      team_name: "$_id",
      total_shots: 1,
      goals_scored: 1,
      conversion_rate_pct: {
        $round: [
          {
            $multiply: [
              { $divide: ["$goals_scored", "$total_shots"] },
              100
            ]
          },
          2
        ]
      }
    }
  },
  { $sort: { conversion_rate_pct: -1, goals_scored: -1, team_name: 1 } },
  { $limit: 10 }
])
```

Obecně tento dotaz demonstruje podmíněnou agregaci pomocí `$cond`. Celkový počet střel se počítá pro každý tým, ale góly se započítají pouze tehdy, když `shot_outcome_name` odpovídá hodnotě `Goal`. V projektu dotaz slouží k porovnání efektivity zakončení týmů ve vybraných zápasech.

### 7.3 Kategorie 3 - Nested / embedded dokumenty

#### Dotaz: Nejaktivnější přihrávající hráči jako vnořený týmový dokument

Cílem dotazu je pro každý zápas a tým vytvořit dokument, který obsahuje základní informace o zápase a vnořené pole `top_passers`.

```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Pass",
      match_id: { $ne: null },
      team_id: { $ne: null },
      player_id: { $ne: null }
    }
  },
  {
    $group: {
      _id: {
        match_id: "$match_id",
        team_id: "$team_id",
        team_name: "$team_name",
        player_id: "$player_id"
      },
      pass_count: { $sum: 1 },
      avg_pass_minute: { $avg: "$minute" },
      distinct_recipients: { $addToSet: "$pass_recipient_id" }
    }
  },
  {
    $lookup: {
      from: "players",
      localField: "_id.player_id",
      foreignField: "player_id",
      as: "player"
    }
  },
  { $unwind: "$player" },
  { $sort: { "_id.match_id": 1, "_id.team_name": 1, pass_count: -1, "_id.player_id": 1 } },
  {
    $group: {
      _id: {
        match_id: "$_id.match_id",
        team_id: "$_id.team_id",
        team_name: "$_id.team_name"
      },
      top_passers: {
        $push: {
          player_id: "$_id.player_id",
          player_name: "$player.player_name",
          country: "$player.country",
          position: "$player.position",
          pass_count: "$pass_count",
          avg_pass_minute: { $round: ["$avg_pass_minute", 2] },
          distinct_recipient_count: {
            $size: {
              $filter: {
                input: "$distinct_recipients",
                as: "recipient",
                cond: { $ne: ["$$recipient", null] }
              }
            }
          }
        }
      },
      total_team_passes: { $sum: "$pass_count" }
    }
  },
  {
    $lookup: {
      from: "matches",
      localField: "_id.match_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $project: {
      _id: 0,
      match_id: "$_id.match_id",
      match_summary: {
        match_date: "$match.match_date",
        home_team: "$match.home_team_name",
        away_team: "$match.away_team_name"
      },
      team: {
        team_id: "$_id.team_id",
        team_name: "$_id.team_name",
        total_team_passes: "$total_team_passes",
        top_passers: { $slice: ["$top_passers", 5] }
      }
    }
  },
  { $sort: { match_id: 1, "team.team_name": 1 } },
  { $limit: 10 }
])
```

Obecně dotaz kombinuje víceúrovňovou agregaci, `$lookup`, `$unwind` a konstrukci vnořeného výstupu. V konkrétním projektu vytváří dokumentově orientovaný výsledek, který je blízký tomu, jak by aplikace mohla konzumovat data z MongoDB: jeden dokument obsahuje souhrn zápasu, tým a pole nejaktivnějších přihrávajících hráčů.

### 7.4 Kategorie 4 - Indexy a výkon

#### Dotaz: Porovnání indexovaného řazení a blokujícího sortu

Cílem dotazu je porovnat dotaz, který může využít složený index `ix_events_season_minute`, s dotazem, který musí provést blokující řazení.

```javascript
function summarize(label, query, sortSpec) {
  let cursor = db.getSiblingDB("statsbomb").events.find(query);
  if (sortSpec) {
    cursor = cursor.sort(sortSpec);
  }

  const exp = cursor.limit(20).explain("executionStats");

  function hasStage(node, stageName) {
    if (!node || typeof node !== "object") return false;
    if (node.stage === stageName) return true;
    if (Array.isArray(node.shards)) {
      return node.shards.some(shard => hasStage(shard.winningPlan || shard, stageName));
    }

    return Object.values(node).some(val =>
      Array.isArray(val)
        ? val.some(item => hasStage(item, stageName))
        : hasStage(val, stageName)
    );
  }

  function findLeaf(node) {
    if (!node || typeof node !== "object") return null;
    if (node.stage === "IXSCAN" || node.stage === "COLLSCAN") return node;
    if (Array.isArray(node.shards)) {
      for (const shard of node.shards) {
        const found = findLeaf(shard.winningPlan || shard);
        if (found) return found;
      }
    }

    for (const val of Object.values(node)) {
      if (Array.isArray(val)) {
        for (const item of val) {
          const found = findLeaf(item);
          if (found) return found;
        }
      } else if (val && typeof val === "object") {
        const found = findLeaf(val);
        if (found) return found;
      }
    }

    return null;
  }

  const leaf = findLeaf(exp.queryPlanner.winningPlan);

  return {
    scenario: label,
    leaf_stage: leaf ? leaf.stage : null,
    index_name: leaf && leaf.indexName ? leaf.indexName : null,
    has_blocking_sort: hasStage(exp.queryPlanner.winningPlan, "SORT"),
    totalDocsExamined: exp.executionStats.totalDocsExamined,
    totalKeysExamined: exp.executionStats.totalKeysExamined,
    nReturned: exp.executionStats.nReturned
  };
}

[
  summarize(
    "indexed season filter + minute sort",
    { season: "2019/2020", minute: { $gte: 75 } },
    { minute: 1 }
  ),
  summarize(
    "non-indexed team_name filter + minute sort",
    { team_name: "Barcelona" },
    { minute: 1 }
  )
]
```

Obecně tento dotaz používá `explain("executionStats")` a porovnává, zda MongoDB použije `IXSCAN`, nebo zda musí provést `COLLSCAN` a blokující `SORT`. V projektu ukazuje praktický význam indexu `{ season: 1, minute: 1 }`, protože indexovaný scénář prochází výrazně menší počet dokumentů.

### 7.5 Kategorie 5 - Cluster, sharding a administrace

#### Dotaz: Audit validačních schémat kolekcí

Cílem dotazu je ověřit, že hlavní kolekce `matches`, `players` a `events` mají aktivní MongoDB JSON Schema validátory.

```javascript
const collInfos = db.getSiblingDB("statsbomb").runCommand({
  listCollections: 1,
  filter: { name: { $in: ["matches", "players", "events"] } }
}).cursor.firstBatch;

collInfos
  .map(function(collection) {
    const schema =
      (collection.options &&
        collection.options.validator &&
        collection.options.validator.$jsonSchema) || {};
    const required = schema.required || [];
    const properties = schema.properties || {};

    return {
      name: collection.name,
      validationLevel: collection.options.validationLevel,
      validationAction: collection.options.validationAction,
      required_fields: required,
      required_field_count: required.length,
      validated_property_count: Object.keys(properties).length
    };
  })
  .sort(function(a, b) {
    return (
      b.required_field_count - a.required_field_count ||
      a.name.localeCompare(b.name)
    );
  });
```

Obecně tento dotaz čte metadata kolekcí a z jejich definice získává informace o validačních pravidlech. V projektu je důležitý proto, že zadání pro MongoDB vyžaduje validační schéma. Výstup potvrzuje, že validace je zapnutá pro všechny tři hlavní kolekce a že běží v režimu `strict` a `error`.

### 7.6 Shrnutí dotazů

Uvedené ukázky pokrývají hlavní typy práce s MongoDB v tomto projektu: spojování kolekcí přes `$lookup`, analytické agregace, tvorbu vnořených dokumentů, práci s indexy a administrativní kontrolu databáze. Všechny dotazy pracují nad propojenými daty `matches`, `players` a `events`.

Do hlavního textu dokumentace není vloženo všech 30 dotazů, protože by to zbytečně výrazně zvětšilo rozsah dokumentace a zhoršilo její čitelnost. Kompletní sada 30 netriviálních dotazů včetně podrobnějších komentářů je proto uvedena v samostatném souboru `Dotazy/mongo_queries.md` a jejich zachycené výsledky jsou v `Dotazy/mongo_query_outputs.md`.

## Závěr

Cílem této semestrální práce bylo navrhnout, implementovat a popsat funkční řešení dokumentové NoSQL databáze MongoDB nad reálnými daty. V projektu byla použita veřejná sportovní data StatsBomb Open Data, konkrétně fotbalová data ze soutěže La Liga pro sezonu 2019/2020. Data byla pomocí Python skriptů zpracována do tří propojených datových sad `matches`, `players` a `events`.

Hlavním výsledkem práce je plně kontejnerizovaný MongoDB sharded cluster spuštěný pomocí Docker Compose. Řešení obsahuje tři config servery, tři shardové replica sety, celkem devět shardových uzlů a jeden `mongos` router. Největší kolekce `events` obsahuje 129 058 dokumentů a je shardována pomocí hashovaného shardovacího klíče `event_id`. Tím je splněn požadavek na práci s větším datovým souborem i požadavek na demonstraci shardingu.

Projekt dále obsahuje replikaci, perzistentní uložení dat pomocí Docker volumes, interní autentizaci mezi uzly pomocí generovaného keyfile, uživatelskou autentizaci a autorizaci, validační schémata kolekcí a indexy podporující hlavní analytické dotazy. Důležitou částí řešení je také automatizace. Po spuštění `docker compose up -d` proběhne inicializace clusteru, vytvoření replica setů, přidání shardů, vytvoření uživatelů, import dat, nastavení validace a vytvoření indexů.

Z hlediska práce s daty projekt ukazuje, že MongoDB je vhodná pro událostní a částečně proměnlivá data. Fotbalové události nemají vždy stejnou strukturu. Například střela obsahuje jiné doplňující atributy než přihrávka, faul nebo karta. Dokumentový model MongoDB proto umožňuje tato data ukládat přirozeněji než striktně relační tabulkový model. Zároveň ale projekt využívá propojení kolekcí pomocí identifikátorů a dotazy s `$lookup`, takže data nejsou izolovaná a lze nad nimi provádět smysluplné analytické úlohy.

V rámci práce bylo připraveno 30 netriviálních MongoDB dotazů rozdělených do pěti kategorií. Dotazy pokrývají spojování kolekcí, agregační statistiky, práci s vnořenými dokumenty, indexy, výkonové ověření a administrativní dotazy nad clusterem. Tím je možné ukázat nejen základní ukládání dat, ale i pokročilejší možnosti MongoDB pro analytické zpracování.

Za silné stránky řešení považuji hlavně automatizované nasazení, použití reálných dat, dostatečný objem hlavní kolekce, sharding mezi tři shardy, replikaci, validační schémata a připravené kontrolní skripty. Složka `evidence` umožňuje doložit stav clusteru, počet dokumentů, indexy, shardování a stav replica setů. To je důležité nejen pro dokumentaci, ale také pro obhajobu, protože popsaná architektura je ověřitelná na skutečně spuštěném řešení.

Řešení má také několik omezení. Cluster běží lokálně na jednom fyzickém zařízení, takže nejde o skutečné produkční geograficky distribuované nasazení. Použit je pouze jeden `mongos` router, zatímco v produkčním prostředí by bylo vhodnější provozovat více routerů a případně load balancer. Hesla jsou nastavena jako ukázkové hodnoty vhodné pro semestrální projekt, nikoli pro produkční použití. Projekt také neobsahuje webovou aplikaci, dashboard ani detailní benchmarky při vysoké zátěži.

I přes tato omezení řešení splňuje hlavní cíl semestrální práce. Projekt prakticky demonstruje, jak lze MongoDB použít jako dokumentovou databázi pro reálná propojená data, jak navrhnout sharded cluster, jak zapnout replikaci a zabezpečení, jak importovat a validovat data a jak nad nimi vytvářet analytické dotazy. Výsledkem není produkční systém, ale funkční a reprodukovatelné demonstrační řešení, které dobře ukazuje klíčové vlastnosti MongoDB v distribuovaném prostředí.

Do budoucna by bylo možné řešení rozšířit například o webové nebo dashboardové rozhraní pro vizualizaci fotbalových statistik, o více `mongos` routerů, o podrobnější výkonové testování, o monitoring clusteru nebo o automatizované zálohování. Dalším možným rozšířením by bylo zpracování větší části původních StatsBomb dat a porovnání výkonu různých shardovacích klíčů. Pro účely semestrální práce je však aktuální rozsah dostatečný a pokrývá požadované části zadání.

## Zdroje

V této kapitole jsou uvedeny zdroje a nástroje použité při zpracování semestrální práce. Zdroje jsou zaměřeny především na MongoDB, Docker, použitá data, případové studie a knihovny použité při analýze dat.

### Použité zdroje

| Zdroj | URL | Použití v práci |
|---|---|---|
| Bosch Digital - MongoDB customer case study | https://www.mongodb.com/solutions/customer-case-studies/bosch | případová studie použití MongoDB v oblasti IoT a big data |
| Docker Docs - Docker Compose | https://docs.docker.com/compose/ | návrh a popis spuštění více kontejnerů pomocí Docker Compose |
| Docker Hub - Docker CLI image | https://hub.docker.com/_/docker | pomocný image `docker:28-cli` pro inicializační službu `cluster-setup` |
| Docker Hub - Mongo image | https://hub.docker.com/_/mongo | oficiální image `mongo:8.0.20` použitý pro MongoDB kontejnery |
| Forbes - MongoDB customer case study | https://www.mongodb.com/solutions/customer-case-studies/forbes | případová studie modernizace CMS a použití MongoDB Atlas |
| Matplotlib documentation | https://matplotlib.org/stable/ | tvorba grafických výstupů v Python analýze dat |
| MongoDB Docs - Authentication | https://www.mongodb.com/docs/manual/core/authentication/ | popis autentizace a zabezpečení MongoDB |
| MongoDB Docs - Indexes | https://www.mongodb.com/docs/manual/indexes/ | popis indexů použitých v kolekci `events` |
| MongoDB Docs - JSON Schema validation | https://www.mongodb.com/docs/manual/core/schema-validation/ | návrh validačních schémat kolekcí |
| MongoDB Docs - Replica Sets | https://www.mongodb.com/docs/manual/replication/ | popis replikace a replica setů |
| MongoDB Docs - Sharding | https://www.mongodb.com/docs/manual/sharding/ | popis shardingu, shardovaných kolekcí a role `mongos` |
| MongoDB Docs - mongoimport | https://www.mongodb.com/docs/database-tools/mongoimport/ | import JSON dat do MongoDB |
| MongoDB Blog - eBay mission-critical applications | https://www.mongodb.com/blog/post/ebay-building-mission-critical-multi-data-center-applications-with-mongodb | případová studie použití MongoDB v e-commerce a multi-data center prostředí |
| pandas documentation | https://pandas.pydata.org/docs/ | zpracování CSV/JSON dat a výpočet základních statistik |
| Python documentation | https://docs.python.org/3/ | skripty pro přípravu a analýzu dat |
| seaborn documentation | https://seaborn.pydata.org/ | tvorba grafů v datové analýze |
| StatsBomb Open Data | https://github.com/statsbomb/open-data | zdroj fotbalových dat použitých v projektu |

### Použité nástroje

| Nástroj | Použití |
|---|---|
| Docker Compose | definice a spuštění MongoDB clusteru |
| Docker Desktop | lokální běh kontejnerů na vývojovém zařízení |
| Docker image `docker:28-cli` | pomocný kontejner pro automatickou inicializaci clusteru |
| Docker image `mongo:8.0.20` | databázové uzly MongoDB, config servery, shardy a `mongos` router |
| Git | správa souborů projektu a verzování |
| Jupyter Notebook | průzkumná analýza dat |
| Matplotlib | tvorba grafických výstupů |
| Microsoft Word | finální zpracování dokumentace ve formátu DOCX |
| MongoDB Database Tools | import dat pomocí `mongoimport` |
| MongoDB Shell `mongosh` | administrace clusteru, ověřovací příkazy a dotazy |
| OpenAI ChatGPT / Codex | pomoc při formulaci textu dokumentace, kontrole struktury a úpravách souborů projektu |
| pandas | načítání, transformace a základní analýza dat |
| PowerShell | spouštění kontrolních a importních skriptů na Windows |
| Python 3 | skripty pro přípravu a analýzu dat |
| seaborn | vizualizace dat v Python analýze |

MongoDB Compass ani Compass Web nejsou součástí spuštěného řešení. Projekt je ověřován pomocí `mongosh`, `mongoimport`, automatizačních skriptů a výstupů ve složce `evidence`. Grafické rozhraní by neměnilo architekturu clusteru, sharding, replikaci ani zabezpečení databáze. V případě potřeby je možné se k databázi připojit z lokální instalace MongoDB Compass přes vystavený `mongos` router na adrese `localhost:27030`.

## Přílohy

Součástí odevzdávaného projektu jsou kromě této dokumentace také datové soubory, skripty, dotazy, konfigurační soubory a kontrolní výstupy. Přílohy jsou rozděleny podle složek projektu tak, aby bylo možné při kontrole nebo obhajobě rychle najít požadovanou část řešení.

### Příloha A - Data

Složka `Data` obsahuje datovou část projektu.

| Cesta | Popis |
|---|---|
| `Data/processed/matches.csv` | připravený CSV soubor se zápasy |
| `Data/processed/matches.json` | JSON soubor importovaný do kolekce `matches` |
| `Data/processed/players.csv` | připravený CSV soubor s hráči |
| `Data/processed/players.json` | JSON soubor importovaný do kolekce `players` |
| `Data/processed/events.csv` | připravený CSV soubor s událostmi |
| `Data/processed/events.json` | JSON soubor importovaný do kolekce `events` |
| `Data/scripts/prepare_statsbomb_data.py` | skript pro vytvoření tří propojených datových sad ze StatsBomb Open Data |
| `Data/scripts/analyze_statsbomb_data.py` | skript pro základní analýzu dat a tvorbu grafů |
| `Data/notebooks/analyze_statsbomb.ipynb` | Jupyter notebook k analýze dat |
| `Data/analysis/data_analysis_report.md` | textový report z analýzy dat |
| `Data/analysis/*.csv` | tabulkové výstupy analýzy, přehledy chybějících hodnot a numerické statistiky |
| `Data/analysis/plots/*.png` | grafické výstupy použité v dokumentaci |

Složka `Data/raw` není součástí odevzdávaného ZIP souboru. Původní surová data jsou veřejně dostupná v repozitáři StatsBomb Open Data a jejich lokální kopie byla příliš rozsáhlá pro přiložení do projektu.

### Příloha B - Dotazy

Složka `Dotazy` obsahuje kompletní sadu MongoDB dotazů.

| Cesta | Popis |
|---|---|
| `Dotazy/mongo_queries.md` | kompletní seznam 30 netriviálních MongoDB dotazů rozdělených do pěti kategorií |
| `Dotazy/mongo_query_outputs.md` | zachycené výstupy všech dotazů |

V hlavním textu dokumentace je z každé kategorie uveden jeden reprezentativní dotaz. Kompletní sada všech dotazů je uvedena právě v této příloze, aby hlavní dokumentace nebyla zbytečně nepřehledná.

### Příloha C - Funkční řešení

Složka `Funkcni_reseni` obsahuje praktickou část projektu potřebnou pro spuštění MongoDB clusteru.

| Cesta | Popis |
|---|---|
| `Funkcni_reseni/docker-compose.yml` | hlavní Docker Compose soubor se službami MongoDB clusteru |
| `Funkcni_reseni/.env.example` | ukázkový soubor proměnných prostředí |
| `Funkcni_reseni/config/mongod-configsvr.conf` | konfigurace config serverů |
| `Funkcni_reseni/config/mongod-shard.conf` | konfigurace shardových uzlů |
| `Funkcni_reseni/config/mongos.conf` | konfigurace `mongos` routeru |
| `Funkcni_reseni/scripts/auto-setup.sh` | automatická inicializace clusteru |
| `Funkcni_reseni/scripts/import-data.ps1` | pomocný skript pro ruční reimport dat |
| `Funkcni_reseni/scripts/pre-defense-check.ps1` | kontrolní skript před obhajobou |
| `Funkcni_reseni/scripts/mongo/post-import-setup.js` | nastavení validačních schémat a indexů |
| `Funkcni_reseni/scripts/mongo/cluster-health.js` | pomocná kontrola stavu clusteru |

### Příloha D - Evidence

Složka `Funkcni_reseni/evidence` obsahuje kontrolní výstupy vytvořené skriptem `pre-defense-check.ps1`. Tyto soubory slouží jako důkaz, že popsané řešení bylo skutečně spuštěno a že odpovídá dokumentované architektuře.

Příklady důležitých výstupů:

| Soubor | Co dokládá |
|---|---|
| `summary/run-summary.json` | souhrn kontroly, verze MongoDB, počty dokumentů a stav replica setů |
| `summary/counts.json` | počet dokumentů v kolekcích `matches`, `players` a `events` |
| `summary/build-info.json` | použitá verze MongoDB |
| `summary/events-stats.json` | statistika kolekce `events`, včetně informace o shardingu a indexech |
| `summary/indexes.json` | seznam vytvořených indexů |
| `summary/admin-users.json` | uživatelé a role v databázi |
| `cluster/sh-status.txt` | stav shardingu v MongoDB clusteru |
| `cluster/events-shard-distribution.txt` | rozdělení kolekce `events` mezi shardy |
| `replica-sets/*-members.json` | stav členů replica setů, role `PRIMARY` a `SECONDARY` |

Tyto výstupy je vhodné použít při obhajobě pro rychlé doložení funkčnosti clusteru, shardingu, replikace, indexů a zabezpečení.

### Příloha E - Dokumentace

Dokumentační část je uložena ve složce `Dokumentace` a ve složce `Data/Pdf_sema/docx`.

| Cesta | Popis |
|---|---|
| `Dokumentace/architektura-prepis.md` | pracovní markdown verze textu dokumentace |
| `Dokumentace/insert_section2_to_docx_ooxml.py` | pomocný skript pro přenos textu do DOCX souboru |
| `Dokumentace/insert_section2_to_docx.ps1` | pomocný PowerShell skript pro práci s Word dokumentem |
| `Data/Pdf_sema/docx/MongoDB-Denys-Tkach-section7-zaver-zdroje.docx` | aktuální verze dokumentace ve formátu DOCX |

Celý projekt je tedy rozdělen tak, aby bylo možné odděleně zkontrolovat data, dotazy, funkční řešení, kontrolní důkazy i samotnou dokumentaci.
