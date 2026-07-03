# Unity meeting cheatsheet

## Korte pitch

Ik heb een procedural terrain systeem in Unity gemaakt. De wereld wordt niet met de hand getekend, maar opgebouwd uit gegenereerde data. Perlin noise maakt hoogte-, temperatuur- en vochtigheidskaarten. Die kaarten bepalen samen de vorm van het terrein, de biomes, de texture blending, sneeuw en decoraties. Rond de viewer worden chunks geladen met verschillende LOD-niveaus, zodat alleen dichtbij veel detail nodig is.

## Wat je als eerste laat zien

Open vooral `Assets/Perlin/Perlin.unity`. Dat is de scene met het terrain systeem. De build settings verwijzen nog naar `Assets/Scenes/SampleScene.unity`, dus open de Perlin scene bewust zelf.

Laat dit in deze volgorde zien:

1. `Map Generator` object met de Inspector settings.
2. Draw Mode wisselen tussen height, temperature, moisture, color map, control maps en mesh.
3. Parameters aanpassen zoals seed, noise scale, octaves en mesh height multiplier.
4. Play Mode starten en bewegen met de viewer/camera.
5. Chunks en LOD uitleggen: dichtbij meer detail, verder weg minder.
6. Decoraties tonen in een biome, bijvoorbeeld bomen in forest.
7. Screenshot fallback: `docs/images/final-world-overview.png`, `docs/images/decorations-biome-example.png`, `docs/images/runtime-chunks-lod.png`.

## De pipeline in gewone taal

De belangrijkste uitleg is:

1. `Noise.cs` maakt ruwe getallen tussen ongeveer 0 en 1.
2. `MapGenerator.cs` maakt drie kaarten: height, temperature en moisture.
3. `BiomeGenerator.cs` kiest per punt welk biome dominant is.
4. `BiomeControlMapGenerator.cs` maakt texture weights voor vloeiende overgangen.
5. `MeshGenerator.cs` zet de height map om naar vertices en triangles.
6. De custom URP shader gebruikt de control maps om terrain textures te mengen.
7. `DecorationGenerator.cs` beslist waar bomen, gras of planten mogen komen.
8. `EndlessTerrain.cs` maakt chunks rond de viewer, kiest LOD en spawnt objecten rustig per frame.

Zeg het ongeveer zo:

> Dezelfde brondata stuurt meerdere systemen. Hoogte bepaalt niet alleen de mesh, maar helpt ook bij biome selectie, texture blending, sneeuw en decoraties. Daardoor spreken de systemen elkaar niet tegen.

## Nieuwe toevoeging: shader en vloeiendere biome-overgangen

Dit is waarschijnlijk het belangrijkste nieuwe stuk om extra goed uit te leggen. Eerder kon je al laten zien dat de generator verschillende biomes kiest. De toevoeging is dat de overgang tussen biomes nu niet alleen een harde kleurwissel is, maar via een custom shader en control maps vloeiender kan worden weergegeven.

Zeg het ongeveer zo:

> Eerst koos het systeem vooral welk biome een punt was. Nu maak ik daarnaast texture weights. Daardoor kan een punt bijvoorbeeld vooral grass zijn, maar ook een beetje forest of mountain meenemen. De shader gebruikt die gewichten om textures vloeiend te mengen.

### Dominant biome versus visuele blend

Er zijn twee verschillende vragen:

1. Welk biome is hier dominant voor gameplay/logica/decoraties?
2. Hoe moet het terrein hier visueel worden gemixt?

`BiomeGenerator.cs` beantwoordt de eerste vraag. Die kiest een biome op basis van height, temperature en moisture.

`BiomeControlMapGenerator.cs` beantwoordt de tweede vraag. Die berekent hoeveel elke texture visueel meetelt. Dat wordt opgeslagen in twee control maps:

- Control Map A: water, beach, plains, forest
- Control Map B: desert, mountain, snow

De shader leest deze maps en mixt daarmee de textures.

### Wat bedoel je met biomes die qua hoogte anders overlopen?

Een biome heeft height ranges, bijvoorbeeld:

- Water: height `0` tot `0.3`
- Beach: height `0.3` tot `0.38`
- Grass/Forest/Desert: middenhoogte
- Mountain/Snow: hogere waardes

Vroeger voelt zoiets vaak als een harde grens: onder `0.3` water, boven `0.3` beach. De toevoeging is dat de visual blending rond zulke grenzen zachter kan zijn. In `BiomeControlMapGenerator` gebeurt dat met `SmoothRangeWeight`. Die geeft niet alleen `0` of `1`, maar een geleidelijke waarde op basis van hoe dicht height, temperature en moisture bij een biome-range liggen.

De belangrijkste instelling hiervoor is:

- `biomeBlendSoftness`: hoe breed/zacht de overgang tussen biome textures is.

Daarnaast zijn er extra variaties:

- `biomeBoundaryNoiseScale`: maakt biome-randen minder recht.
- `biomeBoundaryNoiseHeightInfluence`: laat de hoogteovergang lokaal iets verschuiven.
- `biomePatchNoiseScale`: bepaalt de grootte van kleine texture-variaties.
- `biomePatchNoiseStrength`: bepaalt hoe sterk die variatie is.

Belangrijk om netjes te zeggen:

> De mesh zelf wordt nog steeds door de height map gevormd. Wat ik hier bedoel met overlopen is vooral de visuele overgang tussen biome textures over height ranges. Dus niet dat twee meshes in elkaar overvloeien, maar dat de surface material geleidelijk verandert.

### Waarom is de shader nodig?

Zonder shader zou je vaak een van deze simpele oplossingen hebben:

- Een kleur per biome.
- Een los material per biome.
- Harde grenzen op de mesh.

De custom URP shader doet iets beters:

- Hij gebruikt een material voor het hele terrain.
- Hij leest de control maps.
- Hij mixt zeven texture types.
- Hij mixt niet alleen albedo/kleur, maar ook normal en specular.
- Hij samplet textures in world space, waardoor het patroon doorloopt over chunk-grenzen.

Zeg het ongeveer zo:

> De CPU berekent waar welk biome zit en hoeveel elke texture moet meetellen. De GPU/shader gebruikt die informatie daarna per pixel om het terrein mooi te renderen. Daardoor hoef ik de mesh niet op te splitsen per biome.

### Wat kun je live laten zien?

Laat in de `Map Generator` Draw Mode deze stappen zien:

1. `HeightNoiseMap`: de basis voor hoogte.
2. `TemperatureNoiseMap` en `MoistureNoiseMap`: extra invloeden voor biomes.
3. `ColorMap`: dominante biome preview.
4. `BiomeControlMapA` en `BiomeControlMapB`: de texture weights.
5. `Mesh`: het uiteindelijke terrein met shader/material.

Daarbij kun je zeggen:

> De color map is handig om te debuggen welk biome gekozen wordt. De control maps zijn belangrijker voor de uiteindelijke shader, want die bepalen de vloeiende texture-overgangen.

## Code die je kunt aanwijzen: sneeuw met extra noise

Dit stuk is heel sterk om te laten zien, omdat het precies bewijst dat sneeuw niet meer alleen vanaf een vaste hoogte begint.

### 1. Sneeuw wordt als extra texture weight toegevoegd

Bestand: [BiomeControlMapGenerator.cs](<C:\School\HvA\Jaar 25-26\GPE\GPE-R-D\Assets\Perlin\Scripts\BiomeControlMapGenerator.cs:126>)

```csharp
float snowAmount = GetSnowAmount(height, worldX, worldZ);
if (snowAmount > 0f)
{
    for (int i = 1; i < weights.Length; i++)
    {
        if (i != 6) weights[i] *= 1f - snowAmount;
    }
    weights[6] = Mathf.Max(weights[6], snowAmount);
}
```

Wat je hierbij zegt:

> Eerst bereken ik hoeveel sneeuw er op dit punt moet liggen. Als dat meer dan nul is, worden de andere land-textures minder sterk gemaakt en krijgt de snow texture meer gewicht. Water wordt hier niet meegenomen, omdat de loop bij index 1 begint.

Belangrijk:

- `weights[6]` is de snow texture.
- Sneeuw is dus geen apart object, maar een texture blend in de control map.
- De shader ziet later alleen: op dit punt moet snow zoveel meetellen.

### 2. De sneeuw start niet op exact dezelfde hoogte

Bestand: [BiomeControlMapGenerator.cs](<C:\School\HvA\Jaar 25-26\GPE\GPE-R-D\Assets\Perlin\Scripts\BiomeControlMapGenerator.cs:140>)

```csharp
float start = Mathf.Min(snowStartHeight, snowEndHeight);
float end = Mathf.Max(snowStartHeight, snowEndHeight);
float transition = Mathf.Max(0.0001f, end - start);
float lineNoise = Mathf.PerlinNoise(
    (worldX + snowNoiseOffset.x) / Mathf.Max(0.0001f, snowLineNoiseScale),
    (worldZ + snowNoiseOffset.y) / Mathf.Max(0.0001f, snowLineNoiseScale)
);
float localStart = start + (lineNoise - 0.5f) * snowLineNoiseHeightInfluence * 2f;
```

Wat je hierbij zegt:

> `snowStartHeight` en `snowEndHeight` geven nog steeds de globale hoogteband aan. Maar `lineNoise` verschuift de start lokaal per wereldpositie. Daardoor begint sneeuw op de ene plek iets lager en op de andere plek iets hoger. De sneeuwgrens wordt dus organisch in plaats van een perfecte horizontale lijn.

De belangrijke variabelen:

- `snowStartHeight`: waar sneeuw ongeveer begint.
- `snowEndHeight`: waar sneeuw ongeveer volledig aanwezig mag zijn.
- `snowLineNoiseScale`: hoe groot/grof de golving in de sneeuwlijn is.
- `snowLineNoiseHeightInfluence`: hoe sterk die noise de sneeuwlijn omhoog of omlaag duwt.
- `worldX` en `worldZ`: world-space coordinaten, zodat de noise doorloopt over chunks.

### 3. De sneeuw wordt geleidelijk opgebouwd

Bestand: [BiomeControlMapGenerator.cs](<C:\School\HvA\Jaar 25-26\GPE\GPE-R-D\Assets\Perlin\Scripts\BiomeControlMapGenerator.cs:152>)

```csharp
float amount = Mathf.SmoothStep(
    0f,
    1f,
    Mathf.InverseLerp(localStart, localStart + transition, height)
);
```

Wat je hierbij zegt:

> Dit maakt van de hoogte een waarde tussen 0 en 1. Onder de lokale start is er bijna geen sneeuw. Binnen de overgangsband wordt de sneeuw langzaam sterker. Boven die band is sneeuw bijna volledig aanwezig. `SmoothStep` maakt die overgang zachter dan een harde if-statement.

Vergelijking die je hardop kunt maken:

```csharp
// Simpele oude aanpak:
if (height > snowStartHeight) snow = 1f;

// Nieuwe aanpak:
// height wordt geleidelijk omgerekend naar een snow amount tussen 0 en 1.
```

### 4. Een tweede noise-map haalt gaten uit de sneeuw

Bestand: [BiomeControlMapGenerator.cs](<C:\School\HvA\Jaar 25-26\GPE\GPE-R-D\Assets\Perlin\Scripts\BiomeControlMapGenerator.cs:153>)

```csharp
float holeNoise = Mathf.PerlinNoise(
    (worldX + snowNoiseOffset.x + 913.2f) / Mathf.Max(0.0001f, snowHoleNoiseScale),
    (worldZ + snowNoiseOffset.y + 281.7f) / Mathf.Max(0.0001f, snowHoleNoiseScale)
);
float holeAmount = Mathf.SmoothStep(snowHoleThreshold, 1f, holeNoise) * snowHoleStrength;
return Mathf.Clamp01(amount - holeAmount * (1f - Mathf.SmoothStep(end, 1f, height)));
```

Wat je hierbij zegt:

> Dit is een tweede Perlin noise laag. Die maakt plekken waar de sneeuw minder sterk wordt, alsof er open stukken of vlekken in de sneeuwlijn zitten. Door andere offsets te gebruiken dan bij `lineNoise` krijg ik een ander patroon. Helemaal hoog op de berg blijft sneeuw sterker aanwezig, want de aftrek wordt minder richting de hoogste hoogtes.

De belangrijke variabelen:

- `snowHoleNoiseScale`: hoe groot de gaten/vlekken zijn.
- `snowHoleThreshold`: vanaf welke noise-waarde een gat ontstaat.
- `snowHoleStrength`: hoeveel sneeuw zo'n gat mag weghalen.

Korte samenvatting voor je docent:

> De sneeuw gebruikt drie stappen: een globale hoogteband, een noise-laag die de sneeuwlijn laat golven, en een tweede noise-laag die gaten in de overgang maakt. Daardoor voelt de sneeuw natuurlijker dan een platte grens op een vaste hoogte.

## Code die je kunt aanwijzen: algemene biome-overgangen

Bestand: [BiomeControlMapGenerator.cs](<C:\School\HvA\Jaar 25-26\GPE\GPE-R-D\Assets\Perlin\Scripts\BiomeControlMapGenerator.cs:103>)

```csharp
float weight = SmoothRangeWeight(noisyHeight, biome.minHeight, biome.maxHeight, softness)
    * SmoothRangeWeight(temperature, biome.minTemperature, biome.maxTemperature, softness)
    * SmoothRangeWeight(moisture, biome.minMoisture, biome.maxMoisture, softness);
```

Wat je hierbij zegt:

> Een biome krijgt niet zomaar aan of uit. Het krijgt een gewicht. Dat gewicht wordt bepaald door hoe goed height, temperature en moisture binnen de ranges van dat biome passen. Daardoor kan de shader later meerdere biome textures mengen.

Bestand: [BiomeControlMapGenerator.cs](<C:\School\HvA\Jaar 25-26\GPE\GPE-R-D\Assets\Perlin\Scripts\BiomeControlMapGenerator.cs:161>)

```csharp
static float SmoothRangeWeight(float value, float min, float max, float softness)
{
    float fromMin = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(min - softness, min + softness, value));
    float fromMax = 1f - Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(max - softness, max + softness, value));
    return Mathf.Clamp01(fromMin * fromMax);
}
```

Wat je hierbij zegt:

> Dit is de functie die harde min/max grenzen zachter maakt. Rond de minimumwaarde loopt het gewicht langzaam op. Rond de maximumwaarde loopt het langzaam af. `softness` bepaalt hoe breed die overgang is.

## Hoe voeg je een biome toe?

Er zijn twee soorten biome-uitbreiding. Dit onderscheid is handig als je docent doorvraagt.

### Simpele biome toevoegen met bestaande texture

Dit kan vooral via de Inspector:

1. Open `Assets/Perlin/Perlin.unity`.
2. Selecteer `Map Generator`.
3. Ga naar de `Biomes` array.
4. Verhoog de array size met een nieuw element.
5. Geef het biome een naam, bijvoorbeeld `Swamp`.
6. Kies een bestaande `Texture Type`, bijvoorbeeld `Forest` of `Plains`.
7. Zet `minHeight` en `maxHeight`.
8. Zet `minTemperature` en `maxTemperature`.
9. Zet `minMoisture` en `maxMoisture`.
10. Zet `priority` als het biome overlap heeft met andere biomes.
11. Kies een preview `color`.
12. Voeg optioneel `Decoration Layers` toe.

Dit vereist meestal geen shader-aanpassing, zolang het nieuwe biome een bestaande texture type gebruikt.

Voorbeeld:

> Een swamp-biome zou laag tot middenhoog kunnen zijn, warm, heel vochtig, en visueel de forest- of plains-texture gebruiken. Voor decoraties kun je dan andere prefabs of spawn chances instellen.

### Volledig nieuw texture type toevoegen

Als je echt een achtste soort texture wilt toevoegen, bijvoorbeeld `Swamp` als eigen shader texture, dan is het meer werk:

1. Voeg een waarde toe aan `BiomeTextureType` in `TerrainData.cs`.
2. Verhoog of herdenk `TextureCount` in `BiomeControlMapGenerator.cs`.
3. Pas `GetTextureWeightIndex()` aan.
4. Voeg extra shader properties toe voor de nieuwe texture, normal en specular.
5. Pas de control-map channel-indeling aan.
6. Pas de shader aan zodat hij de nieuwe weight leest en mixt.
7. Pas eventueel het texture assignment tool aan.

Zeg hierbij:

> Een nieuw biome met bestaande visual style is data-driven. Een compleet nieuw texture channel toevoegen raakt ook de shader en control-map layout.

## Belangrijkste scripts

`Assets/Perlin/Scripts/Noise.cs`

Maakt Perlin noise. Het systeem gebruikt meerdere octaves: de eerste laag geeft grote vormen, latere lagen geven detail. Scale bepaalt hoe groot of klein patronen worden. Persistence bepaalt hoeveel invloed latere lagen houden. Lacunarity bepaalt hoe snel de frequentie stijgt.

`Assets/Perlin/Scripts/MapGenerator.cs`

Dit is de centrale coordinator. Hier staan de settings voor noise, terrain height, biome blending, snow en biomes. Deze class start background threads voor map data, mesh data en decoration data. De resultaten komen terug via queues en worden in `Update()` afgehandeld op de Unity main thread.

`Assets/Perlin/Scripts/TerrainData.cs`

Bevat de data structs: `BiomeType`, `DecorationLayer`, `MapData` en `DecorationSpawnData`. Dit maakt het systeem data-driven: biomes en decoration layers kunnen via Inspector settings worden aangepast.

`Assets/Perlin/Scripts/BiomeGenerator.cs`

Kiest een biome op basis van min/max ranges voor height, temperature en moisture. Als meerdere biomes matchen, wint de hoogste priority. Als niets exact matcht, kiest hij het dichtstbijzijnde biome, zodat er geen lege stukken ontstaan.

`Assets/Perlin/Scripts/BiomeControlMapGenerator.cs`

Maakt twee control maps voor zeven texture weights: water, beach, plains, forest, desert, mountain en snow. Een gewone biome index kan maar een ding tegelijk zeggen, maar control maps kunnen zeggen hoeveel elke texture bijdraagt. Daardoor krijg je vloeiendere overgangen.

`Assets/Perlin/Materials/ProceduralBiomeTexturesURP_Final.shader`

De shader leest Control Map A en B. Daarna samplet hij de terrain textures in world space, zodat de texture niet per chunk opnieuw begint. Hij mixt albedo, normal en specular met dezelfde weights, waardoor de overgang niet alleen kleur is maar ook lichtdetail meeneemt.

`Assets/Perlin/Scripts/MeshGenerator.cs`

Zet de height map om naar een mesh. Elke sample wordt een vertex met een Y-hoogte. Daarna worden triangles gemaakt. LOD werkt door niet elke sample te gebruiken: een hogere LOD-waarde slaat meer punten over.

`Assets/Perlin/Scripts/EndlessTerrain.cs`

Regelt runtime streaming. Het bepaalt in welke chunk de viewer staat, maakt ontbrekende chunks aan en verbergt chunks buiten de view distance. Het kiest per chunk een LOD op basis van afstand. Decoraties worden alleen dichtbij getoond en maximaal twintig per frame gespawned.

`Assets/Perlin/Scripts/DecorationGenerator.cs`

Maakt spawn data voor decoraties. Het kijkt naar biome, noise threshold, spawn chance, minimum distance en random scale/rotation. Belangrijk: het maakt alleen data op de background thread. Het echte `Instantiate` gebeurt later in `EndlessTerrain`, op de main thread.

## Concrete scene settings die je kunt noemen

In de huidige `Perlin.unity` scene:

- Noise scale: `200`
- Octaves: `4`
- Persistence: `0.5`
- Lacunarity: `2`
- Mesh height multiplier: `80`
- Chunk map size: `241`, dus de mesh gebruikt `240` tussenstappen per chunk.
- LOD afstanden: `200`, `400`, `600`
- Biomes: Water, Beach, Desert, Grass, Forest, Snow, Mountain
- Snow start rond height `0.75`, volledige snow rond `0.85`

## Hoe je het uitlegt aan je docent

### Waarom Perlin noise?

Pure random waardes geven losse pieken en chaos. Perlin noise geeft vloeiende waarden, dus buren lijken op elkaar. Dat is geschikt voor terrein, omdat bergen, dalen en oevers geleidelijk moeten verlopen.

### Waarom drie kaarten?

Alleen hoogte is beperkt. Dan zou elk laag gebied water zijn en elk hoog gebied berg. Door temperatuur en vochtigheid toe te voegen, kan dezelfde hoogte toch desert, grass of forest worden. Dat geeft meer variatie zonder een compleet andere mesh generator.

### Waarom biomes met ranges en priority?

Het is makkelijk te tunen in de Inspector. Een biome heeft ranges voor height, temperature en moisture. Priority lost overlap op. Water en beach kunnen bijvoorbeeld belangrijker zijn dan algemene grass ranges.

### Waarom control maps?

Een biome index is hard: dit punt is forest of grass. Voor visuals wil je soms een mix: 70 procent grass, 30 procent forest. Daarom worden twee textures gebruikt als gewichtskaarten. De shader gebruikt die weights om zeven terrain textures te mengen.

### Waarom chunks?

Een endless world kun je niet volledig tegelijk genereren. Chunks zorgen dat alleen de omgeving rond de speler/viewer actief is. Als de viewer beweegt, worden nieuwe chunks gemaakt of bestaande chunks geupdatet.

### Waarom LOD?

Dichtbij zie je details, ver weg niet. LOD verlaagt het aantal vertices voor verre chunks. De onderliggende werelddata blijft hetzelfde, maar de mesh wordt eenvoudiger weergegeven.

### Waarom threads?

Noise maps, mesh data en spawn decisions kosten tijd. Die kunnen op background threads worden voorbereid. Unity objecten zoals `Mesh`, `Texture2D`, `Material` en `GameObject.Instantiate` moeten veilig op de main thread gebeuren. Daarom zet het systeem resultaten in queues en verwerkt `MapGenerator.Update()` ze later.

## Sterke punten

- De systemen zijn gekoppeld via dezelfde data: height, temperature en moisture.
- Het project is data-driven: biomes en decoraties zijn Inspector-instellingen.
- De rendering gebruikt control maps voor vloeiende texture blends.
- World-space shader sampling voorkomt dat textures per chunk opnieuw starten.
- Chunks en LOD maken het systeem schaalbaarder.
- Background calculation en main-thread handoff laten zien dat er rekening is gehouden met Unity performance regels.
- Decoratie-spawns zijn deterministic door seed, chunk position en tile position.

## Eerlijke beperkingen en verbeterpunten

Als je docent vraagt wat beter kan:

- Eerst profilen voordat je optimaliseert: CPU generation, texture creation, shader cost, object count.
- Voor veel meer chunks is een thread pool, Tasks of Unity Jobs/Burst beter dan losse raw threads.
- De shader samplet veel textures; texture arrays of dominant-layer shortcuts kunnen later helpen.
- Decoraties zijn nu GameObjects; bij enorme aantallen zijn pooling, GPU instancing of terrain details logischer.
- Het texture assignment tool gebruikt `UnityEditor` en hoort voor builds idealiter in een `Editor` folder.
- De build settings staan nog op `SampleScene`; voor een demo moet `Assets/Perlin/Perlin.unity` bewust geopend worden.

## Mogelijke docentvragen

**Vraag: Wat is er nieuw ten opzichte van je eerdere versie?**

De eerdere versie kon al procedureel terrain en biomes genereren. De toevoeging is vooral de visuele laag: een custom URP shader met control maps. Daardoor zijn biome-overgangen niet alleen harde kleuren of losse materials, maar gemixte textures met albedo, normal en specular. Ook kan de overgang rond height ranges zachter en organischer worden gemaakt met blend softness en noise.

**Vraag: Wat heb jij technisch vooral geleerd?**

Dat procedural generation niet alleen noise is. Het echte werk zit in de pipeline eromheen: data normaliseren, betekenis geven via biomes, visuals blenden, runtime streaming doen en performance beheersbaar houden.

**Vraag: Waarom is dit beter dan een handgemaakte map?**

Een handgemaakte map is controleerbaar, maar beperkt. Dit systeem kan met een seed steeds dezelfde wereld opnieuw maken en chunks genereren waar nodig. Dat past beter bij een grote of endless wereld.

**Vraag: Waarom niet gewoon Unity Terrain gebruiken?**

Unity Terrain is sterk als ingebouwde terrain tool, maar ik wilde het proces zelf begrijpen en controleren: hoe height data mesh vertices wordt, hoe biomes gekozen worden en hoe texture weights naar een custom shader gaan.

**Vraag: Wat gebeurt er als ranges elkaar overlappen?**

Dan wint de biome met de hoogste priority. Dat is bewust, zodat specifieke biomes zoals water, beach, snow of mountain voorrang kunnen krijgen boven bredere categorieen.

**Vraag: Wat gebeurt er als geen biome matcht?**

Dan kiest het systeem het dichtstbijzijnde biome. Daardoor krijg je geen lege of magenta stukken tijdens tuning.

**Vraag: Hoe voeg je een biome toe?**

Als het biome een bestaande texture type mag gebruiken, voeg je vooral een element toe aan de `Biomes` array in de Inspector. Daar stel je naam, height range, temperature range, moisture range, priority, preview color en eventuele decoration layers in. Als het biome een compleet eigen texture channel nodig heeft, moet ook de enum, control-map generator, shader en material setup worden uitgebreid.

**Vraag: Waarom gebruik je niet gewoon een material per biome?**

Dan krijg je sneller harde grenzen of extra submeshes/material management per chunk. Met control maps kan dezelfde chunk meerdere biome textures vloeiend mengen met een material.

**Vraag: Wat is het verschil tussen de color map en control maps?**

De color map is vooral een debug/preview van het dominante biome. De control maps zijn shader input: ze slaan per pixel/texel op hoeveel water, beach, plains, forest, desert, mountain en snow visueel moeten meetellen.

**Vraag: Wat bedoel je met height-based overgangen?**

Biomes hebben min/max height ranges. Rond die ranges gebruikt het systeem geen pure harde grens voor de visuals, maar gewichten via `SmoothRangeWeight`. Daardoor kan bijvoorbeeld grass geleidelijk overgaan naar mountain of snow, in plaats van op een exacte hoogte ineens te wisselen.

**Vraag: Waarom mogen Unity objecten niet in worker threads worden aangepast?**

Unity APIs zijn grotendeels main-thread gebonden. Daarom bereken ik gewone C# data op worker threads en pas ik textures, meshes en GameObjects pas toe op de main thread.

**Vraag: Wat zou je als volgende stap doen?**

Ik zou eerst de profiler gebruiken. Daarna zou ik gericht verbeteren: jobs of thread pool voor scheduling, pooling of instancing voor decoraties, en shader optimalisatie als GPU-kosten hoog blijken.

## Korte afsluiting

Mijn project laat zien hoe je van eenvoudige noise naar een complete Unity terrain pipeline gaat. De kern is dat dezelfde gegenereerde data wordt hergebruikt voor mesh, biomes, textures, sneeuw, decoratie en runtime chunking. Daardoor is het systeem uitlegbaar, uitbreidbaar en technisch logisch opgebouwd.
