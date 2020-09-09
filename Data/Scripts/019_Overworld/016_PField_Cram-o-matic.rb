#===============================================================================
# Cram-o-Matic - By Vendily and KyureJL
#===============================================================================
# This script adds in the Cram-o-Matic, the combinational machine from the SwSh
#  Isle of Armor DLC.
#===============================================================================
# The you only need to call pbCramOMatic in an event, and the script will allow
#  you to pick 4 items to convert. Canceling early returns the items.
#  Only items in CRAMOMATIC_ITEMDATA can be chosen.
#
# CRAMOMATIC_ITEMDATA contains entries where the key is the symbol for the item
#  and the value is an array of the item type (doesn't actually have to be a type)
#  and the value of the item.
#
# There are a few hard coded recipies, and the generic type based recipies
#  are defined in CRAMOMATIC_TYPERECIPIES
#
# CRAMOMATIC_TYPERECIPIES contains entries where the key is the type (doesn't 
#  have to be a type) and the value is an array of item symbols. The array has to 
#  be the same length as CRAMOMATIC_RATIO. You can set a slot as an array of
#  item symbols to pick one at random.
#===============================================================================

CRAMOMATIC_ITEMDATA={
  :BUGMEMORY=>[:BUG,40],
  :GRIPCLAW=>[:BUG,26],
  :SILVERPOWDER=>[:BUG,10],
  :SHEDSHELL=>[:BUG,10],
  :TANGABERRY=>[:BUG,4],
  :ENIGMABERRY=>[:BUG,10],
  :HONEY=>[:BUG,2],
  
  :DARKMEMORY=>[:DARK,40],
  :BINDINGBAND=>[:DARK,8],
  :BLKAPRICORN=>[:DARK,0],
  :BLACKAPRICORN=>[:DARK,0],
  :BLACKGLASSES=>[:DARK,14],
  :BLUNDERPOLICY=>[:DARK,24],
  :COLBURBERRY=>[:DARK,4],
  :DUBIOUSDISC=>[:DARK,32],
  :IAPAPABERRY=>[:DARK,4],
  :MARANGABERRY=>[:DARK,6],
  :RAZORCLAW=>[:DARK,26],
  :RINGTARGET=>[:DARK,14],
  :ROWAPBERRY=>[:DARK,6],
  :SCOPELENS=>[:DARK,12],
  :WEAKNESSPOLICY=>[:DARK,30],
  :WIDELENS=>[:DARK,22],
  :ZOOMLENS=>[:DARK,22],
    
  :DRAGONMEMORY=>[:DRAGON,40],
  :EVIOLITE=>[:DRAGON,32],
  :LIFEORB=>[:DRAGON,20],
  :DRAGONFANG=>[:DRAGON,18],
  :DRAGONSCALE=>[:DRAGON,18],
  :FOSSILIZEDDRAKE=>[:DRAGON,10],
  :DYNAMAXCANDY=>[:DRAGON,6],
  :JABOCABERRY=>[:DRAGON,6],
  :AGUAVBERRY=>[:DRAGON,4],
  :HABANBERRY=>[:DRAGON,4],
  
  :ELECTRICMEMORY=>[:ELECTRIC,40],
  :LIGHTBALL=>[:ELECTRIC,20],
  :MAGNET=>[:ELECTRIC,20],
  :CELLBATTERY=>[:ELECTRIC,14],
  :FOSSILIZEDBIRD=>[:ELECTRIC,10],
  :ELECTRICSEED=>[:ELECTRIC,8],
  :THUNDERSTONE=>[:ELECTRIC,6],
  :WACANBERRY=>[:ELECTRIC,4],
  :PECHABERRY=>[:ELECTRIC,2],
  :YLWAPRICORN=>[:ELECTRIC,0],
  :YELLOWAPRICORN=>[:ELECTRIC,0],
  
  :FAIRYMEMORY=>[:FAIRY,40],
  :BERRYSWEET=>[:FAIRY,30],
  :CLOVERSWEET=>[:FAIRY,30],
  :FLOWERSWEET=>[:FAIRY,30],
  :LOVESWEET=>[:FAIRY,30],
  :RIBBONSWEET=>[:FAIRY,30],
  :STARSWEET=>[:FAIRY,30],
  :STRAWBERRYSWEET=>[:FAIRY,30],
  :WHIPPEDDREAM=>[:FAIRY,26],
  :SACHET=>[:FAIRY,20],
  :BRIGHTPOWDER=>[:FAIRY,14],
  :MISTYSEED=>[:FAIRY,8],
  :KEEBERRY=>[:FAIRY,6],
  :MOONSTONE=>[:FAIRY,40],
  :SHINYSTONE=>[:FAIRY,6],
  :ROSELIBERRY=>[:FAIRY,4],
  :PIXIEPLATE=>[:FAIRY,2],
  :PNKAPRICORN=>[:FAIRY,0],
  :PINKAPRICORN=>[:FAIRY,0],
  
  :FIGHTINGMEMORY=>[:FIGHTING,40],
  :EXPERTBELT=>[:FIGHTING,32],
  :ARMORITEORE=>[:FIGHTING,28],
  :MACHOBRACE=>[:FIGHTING,26],
  :CHOICEBAND=>[:FIGHTING,20],
  :POWERANKLET=>[:FIGHTING,20],
  :POWERBAND=>[:FIGHTING,20],
  :POWERBELT=>[:FIGHTING,20],
  :POWERBRACER=>[:FIGHTING,20],
  :BLACKBELT=>[:FIGHTING,14],
  :MUSCLEBAND=>[:FIGHTING,14],
  :FOCUSBAND=>[:FIGHTING,12],
  :FOCUSSASH=>[:FIGHTING,12],
  :PROTECTIVEPADS=>[:FIGHTING,12],
  :SALACBERRY=>[:FIGHTING,12],
  :KELPSYBERRY=>[:FIGHTING,6],
  :CALCIUM=>[:FIGHTING,4],
  :CARBOS=>[:FIGHTING,4],
  :CHOPLEBERRY=>[:FIGHTING,4],
  :HPUP=>[:FIGHTING,4],
  :IRON=>[:FIGHTING,4],
  :PROTEIN=>[:FIGHTING,4],
  :ZINC=>[:FIGHTING,4],
  :LEPPABERRY=>[:FIGHTING,2],
  
  :FIREMEMORY=>[:FIRE,40],
  :CHARCOAL=>[:FIRE,32],
  :REDCARD=>[:FIRE,16],
  :FLAMEORB=>[:FIRE,14],
  :HEATROCK=>[:FIRE,12],
  :FIRESTONE=>[:FIRE,6],
  :SUNSTONE=>[:FIRE,6],
  :FIGYBERRY=>[:FIRE,4],
  :OCCABERRY=>[:FIRE,4],
  :CHERIBERRY=>[:FIRE,2],
  :REDAPRICORN=>[:FIRE,0],
  
  :FLYINGMEMORY=>[:FLYING,40],
  :UTILITYUMBRELLA=>[:FLYING,20],
  :AIRBALLOON=>[:FLYING,20],
  :SHARPBEAK=>[:FLYING,10],
  :LANSATBERRY=>[:FLYING,10],
  :CLEVERFEATHER=>[:FLYING,6],
  :GENIOUSFEATHER=>[:FLYING,6],
  :GREPABERRY=>[:FLYING,6],
  :HEALTHFEATHER=>[:FLYING,6],
  :MUSCLEFEATHER=>[:FLYING,6],
  :PRETTYFEATHER=>[:FLYING,6],
  :RESISTFEATHER=>[:FLYING,6],
  :SWIFTFEATHER=>[:FLYING,6],
  :COBABERRY=>[:FLYING,4],
  :LUMBERRY=>[:FLYING,2],
  
  :GHOSTREMORY=>[:GHOST,40],
  :REAPERCLOTH=>[:GHOST,32],
  :SPELLTAG=>[:GHOST,26],
  :CLEANSETAG=>[:GHOST,24],
  :ADRENALINEORB=>[:GHOST,12],
  :CUSTAPBERRY=>[:GHOST,10],
  :DUSKSTONE=>[:GHOST,6],
  :KASIBBERRY=>[:GHOST,4],
  :MAGOBERRY=>[:GHOST,4],
  :ODDINCENSE=>[:GHOST,2],
  
  :GRASSMEMORY=>[:GRASS,40],
  :SWEETAPPLE=>[:GRASS,30],
  :TARTAPPLE=>[:GRASS,30],
  :BALMMUSHROOM=>[:GRASS,24],
  :LEFTOVERS=>[:GRASS,20],
  :LEEK=>[:GRASS,18],
  :ADAMANTRINT=>[:GRASS,16],
  :BOLDMINT=>[:GRASS,16],
  :BRAVEMINT=>[:GRASS,16],
  :CALMMINT=>[:GRASS,16],
  :CAREFULMINT=>[:GRASS,16],
  :GENTLEMINT=>[:GRASS,16],
  :HASTYMINT=>[:GRASS,16],
  :IMPISHMINT=>[:GRASS,16],
  :LAXMINT=>[:GRASS,16],
  :LONELYMINT=>[:GRASS,16],
  :MILDMINT=>[:GRASS,16],
  :MODESTRINT=>[:GRASS,16],
  :NAIVEMINT=>[:GRASS,16],
  :NAUGHTYMINT=>[:GRASS,16],
  :QUIETRINT=>[:GRASS,16],
  :RASHMINT=>[:GRASS,16],
  :RELAXEDMINT=>[:GRASS,16],
  :SASSYMINT=>[:GRASS,16],
  :SERIOUSMINT=>[:GRASS,16],
  :TIMIDMINT=>[:GRASS,16],
  :BIGMUSHROOM=>[:GRASS,14],
  :MENTALHERB=>[:GRASS,14],
  :MIRACLESEED=>[:GRASS,14],
  :WHITEHERB=>[:GRASS,14],
  :LIECHIBERRY=>[:GRASS,12],
  :POWERHERB=>[:GRASS,10],
  :STICKYBARB=>[:GRASS,10],
  :ABSORBBULB=>[:GRASS,8],
  :BIGROOT=>[:GRASS,8],
  :GRASSYSEED=>[:GRASS,8],
  :LUMINOUSMOSS=>[:GRASS,8],
  :LEAFSTONE=>[:GRASS,6],
  :GALARICATWIG=>[:GRASS,4],
  :RINDOBERRY=>[:GRASS,4],
  :RAWSTBERRY=>[:GRASS,2],
  :ROSEINCENSE=>[:GRASS,2],
  :TINYMUSHROOM=>[:GRASS,2],
  :GRNAPRICORN=>[:GRASS,0],
  :GREENAPRICORN=>[:GRASS,0],
  
  :GROUNDMEMORY=>[:GROUND,40],
  :BIGNUGGET=>[:GROUND,38],
  :CHIPPEDPOT=>[:GROUND,36],
  :CRACKEDPOT=>[:GROUND,30],
  :SOFTSAND=>[:GROUND,20],
  :THICKCLUB=>[:GROUND,18],
  :NUGGET=>[:GROUND,16],
  :HEAVYDUTYBOOTS=>[:GROUND,16],
  :APICOTBERRY=>[:GROUND,12],
  :RAREBONE=>[:GROUND,12],
  :TERRAINEXTENDER=>[:GROUND,12],
  :STARDUST=>[:GROUND,8],
  :HONDEWBERRY=>[:GROUND,6],
  :SHUCABERRY=>[:GROUND,4],
  :PERSIMBERRY=>[:GROUND,2],
  
  :ICEMEMORY=>[:ICE,40],
  :COMETSHARD=>[:ICE,34],
  :NEVERMELTICE=>[:ICE,14],
  :GANLONBERRY=>[:ICE,12],
  :ICYROCK=>[:ICE,12],
  :FOSSILIZEDDINO=>[:ICE,10],
  :SNOWBALL=>[:ICE,8],
  :ICESTONE=>[:ICE,6],
  :POMEGBERRY=>[:ICE,6],
  :YACHEBERRY=>[:ICE,4],
  :ASPEARBERRY=>[:ICE,2],
  
  :ABILITYCAPSULE=>[:NORMAL,40],
  :PPMAX=>[:NORMAL,40],
  :PPUP=>[:NORMAL,38],
  :AMULETCOIN=>[:NORMAL,32],
  :UPGRADE=>[:NORMAL,30],
  :QUICKPOWDER=>[:NORMAL,28],
  :QUICKCLAW=>[:NORMAL,26],
  :SILKSCARF=>[:NORMAL,22],
  :CHOICESCARF=>[:NORMAL,20],
  :LUCKYEGG=>[:NORMAL,20],
  :SAFETYGOGGLES=>[:NORMAL,10],
  :NORMALGEM=>[:NORMAL,8],
  :CHILANBERRY=>[:NORMAL,4],
  :FULLINCENSE=>[:NORMAL,2],
  :LUCKINCENSE=>[:NORMAL,2],
  :WHTAPRICORN=>[:NORMAL,0],
  :WHITEAPRICORN=>[:NORMAL,0],
  
  :POISONMEMORY=>[:POISON,40],
  :POISONBARB=>[:POISON,32],
  :WISHINGPIECE=>[:POISON,28],
  :SMOKEBALL=>[:POISON,22],
  :GALARICACUFF=>[:POISON,18],
  :TOXICORB=>[:POISON,14],
  :PETAYABERRY=>[:POISON,12],
  :BLACKSLUDGE=>[:POISON,10],
  :QUALOTBERRY=>[:POISON,6],
  :KEBIABERRY=>[:POISON,4],
  :MAXREPEL=>[:POISON,2],
  :ORANBERRY=>[:POISON,2],
  :REPEL=>[:POISON,2],
  :SUPERREPEL=>[:POISON,2],
  
  :RARECANDY=>[:PSYCHIC,40],
  :PSYCHICMEMORY=>[:PSYCHIC,40],
  :DESTINYKNOT=>[:PSYCHIC,28],
  :ROOMSERVICE=>[:PSYCHIC,24],
  :CHOICESPECS=>[:PSYCHIC,20],
  :LIGHTCLAY=>[:PSYCHIC,20],
  :POWERLENS=>[:PSYCHIC,20],
  :TWISTEDSPOON=>[:PSYCHIC,18],
  :EXPCANDYXL=>[:PSYCHIC,10],
  :STARFBERRY=>[:PSYCHIC,10],
  :WISEGLASSES=>[:PSYCHIC,10],
  :EXPCANDYL=>[:PSYCHIC,8],
  :PSYCHICSEED=>[:PSYCHIC,8],
  :DAWNSTONE=>[:PSYCHIC,6],
  :EXPCANDYM=>[:PSYCHIC,6],
  :TAMATOBERRY=>[:PSYCHIC,6],
  :EXPCANDYS=>[:PSYCHIC,4],
  :PAYAPABERRY=>[:PSYCHIC,4],
  :EXPCANDYXS=>[:PSYCHIC,2],
  :LAXINCENSE=>[:PSYCHIC,2],
  :PUREINCENSE=>[:PSYCHIC,2],
  :SITRUSBERRY=>[:PSYCHIC,2],
  
  :ROCKMEMORY=>[:ROCK,40],
  :ROCKYHELMET=>[:ROCK,26],
  :PROTECTOR=>[:ROCK,24],
  :EVERSTONE=>[:ROCK,20],
  :STARPIECE=>[:ROCK,20],
  :HARDSTONE=>[:ROCK,14],
  :OVALSTONE=>[:ROCK,12],
  :SMOOTHROCK=>[:ROCK,12],
  :LAGGINGTAIL=>[:ROCK,10],
  :MICLEBERRY=>[:ROCK,10],
  :FLOATSTONE=>[:ROCK,8],
  :CHARTIBERRY=>[:ROCK,4],
  :WIKIBERRY=>[:ROCK,4],
  :ROCKINCENSE=>[:ROCK,2],
  
  :BOTTLECAP=>[:STEEL,40],
  :GOLDBOTTLECAP=>[:STEEL,40],
  :STEELMEMORY=>[:STEEL,40],
  :KINGSROCK=>[:STEEL,32],
  :METALCOAT=>[:STEEL,24],
  :METRONOME=>[:STEEL,22],
  :ASSAULTVEST=>[:STEEL,20],
  :EJECTBUTTON=>[:STEEL,16],
  :EJECTPACK=>[:STEEL,16],
  :IRONBALL=>[:STEEL,16],
  :METALPOWDER=>[:STEEL,14],
  :SOOTHEBELL=>[:STEEL,14],
  :BABIRIBERRY=>[:STEEL,4],
  :RUSTEDSHIELD=>[:STEEL,2],
  :RUSTEDSWORD=>[:STEEL,2],
  
  :WATERMEMORY=>[:WATER,40],
  :PEARLSTRING=>[:WATER,30],
  :PRISMSCALE=>[:WATER,26],
  :SHELLBELL=>[:WATER,14],
  :BIGPEARL=>[:WATER,12],
  :DAMPROCK=>[:WATER,12],
  :THROATSPRAY=>[:WATER,12],
  :FOSSILIZEDFISH=>[:WATER,10],
  :MYSTICWATER=>[:WATER,10],
  :PEARL=>[:WATER,6],
  :WATERSTONE=>[:WATER,6],
  :PASSHOBERRY=>[:WATER,4],
  :CHESTOBERRY=>[:WATER,2],
  :SEAINCENSE=>[:WATER,2],
  :WAVEINCENSE=>[:WATER,2],
  :BLUAPRICORN=>[:WATER,0],
  :BLUEAPRICORN=>[:WATER,0],
}

CRAMOMATIC_TYPERECIPIES={
  :BUG=>[:TR60,:TR18,:BRIGHTPOWDER,:WISHINGPIECE,:SILVERPOWDER,:BALMMUSHROOM,:TR61,:SHEDSHELL,:PEARLSTRING,:TR96,:COMETSHARD,:TR28,:RARECANDY,:BOTTLECAP,:PPUP],
  :DARK=>[:TR37,:WIDELENS,:TR68,:WISHINGPIECE,:STARPIECE,:BALMMUSHROOM,:TR81,:SCOPELENS,:TR95,:TR58,:TR32,:TR93,:RARECANDY,:BOTTLECAP,:PPUP],
  :DRAGON=>[:TR47,:DRAGONFANG,:BIGMUSHROOM,:WISHINGPIECE,:STARPIECE,:BALMMUSHROOM,:DRAGONSCALE,:LIFEORB,:TR62,:KINGSROCK,:TR51,:TR24,:RARECANDY,:BOTTLECAP,:PPUP],
  :ELECTRIC=>[:ELECTRICSEED,:TR80,:CELLBATTERY,:WISHINGPIECE,:MAGNET,:TR86,:UPGRADE,:LIGHTBALL,:PEARLSTRING,:DUBIOUSDISC,:TR08,:TR09,:RARECANDY,:BOTTLECAP,:PPUP],
  :FAIRY=>[:STARDUST,:MISTYSEED,:BIGMUSHROOM,:WISHINGPIECE,:SACHET,:ROOMSERVICE,:WHIPPEDDREAM,:DESTINYKNOT,
    [:BERRYSWEET,:CLOVERSWEET,:FLOWERSWEET,:LOVESWEET,:STRAWBERRYSWEET],:TR92,
    [:RIBBONSWEET,:STARSWEET,:STRAWBERRYSWEET],:TR90,:RARECANDY,:BOTTLECAP,:PPUP],
  :FIGHTING=>[:TR07,:TR56,:MUSCLEBAND,:WISHINGPIECE,:TR48,:TR21,:MACHOBRACE,:TM00,:EXPERTBELT,:TR64,:TR39,:TR53,:RARECANDY,:BOTTLECAP,:PPUP],
  :FIRE=>[:TR88,:FLAMEORB,:TR41,:WISHINGPIECE,:TR02,:BALMMUSHROOM,:TR36,:REDCARD,:TR15,:CHARCOAL,:TR55,:TR43,:RARECANDY,:BOTTLECAP,:PPUP],
  :FLYING=>[:PRETTYFEATHER,:SHARPBEAK,:BIGMUSHROOM,:WISHINGPIECE,:AIRBALLOON,:BLUNDERPOLICY,:GRIPCLAW,:AIRBALLOONN,:WEAKNESSPOLICY,:TR89,:COMETSHARD,:TR66,:RARECANDY,:BOTTLECAP,:PPUP],
  :GHOST=>[:ODDINCENSE,:ADRENALINEORB,:RINGTARGET,:WISHINGPIECE,:STARPIECE,:BALMMUSHROOM,:CLEANSETAG,:SPELLTAG,:CRACKEDPOT,:REAPERCLOTH,:COMETSHARD,:TR33,:RARECANDY,:BOTTLECAP,:PPUP],
  :GRASS=>[:GRASSYSEED,:TR59,:WHITEHERB,:WISHINGPIECE,:TR77,:TR50,:TR65,:ABSORBBULB,:PEARLSTRING,:TR72,:COMETSHARD,:TR71,:RARECANDY,:BOTTLECAP,:PPUP],
  :GROUND=>[:STARDUST,:TR23,:BIGMUSHROOM,:WISHINGPIECE,:LIGHTCLAY,:TR87,:TR67,:TERRAINEXTENDER,:PEARLSTRING,:TR94,:COMETSHARD,:TR10,:RARECANDY,:BOTTLECAP,:PPUP],
  :ICE=>[:SNOWBALL,:ICYROCK,:NEVERMELTICE,:WISHINGPIECE,:STARPIECE,:BALMMUSHROOM,:RAZORCLAW,:SNOWBALL,:PEARLSTRING,:TR05,:COMETSHARD,:TR06,:RARECANDY,:BOTTLECAP,:PPUP],
  :NORMAL=>[:TR85,:TR14,:TR26,:TR13,:TR27,:TR35,:TR01,:TR19,:TR29,:TR30,:TR20,:TR00,:TR42,:BOTTLECAP,:PPUP],
  :POISON=>[:BLACKSLUDGE,:TOXICORB,:TR91,:WISHINGPIECE,:TR54,:SMOKEBALL,:TR57,:QUICKPOWDER,:POISONBARB,:TR22,:TR78,:TR73,:RARECANDY,:BOTTLECAP,:PPUP],
  :PSYCHIC=>[:TR12,:TR34,:TR40,:TR82,:TR44,:TR83,:TR25,:TR69,:TR17,:TR38,:TR49,:TR97,:TR11,:BOTTLECAP,:PPUP],
  :ROCK=>[:FLOATSTONE,:OVALSTONE,:HARDSTONE,:WISHINGPIECE,:EVERSTONE,:PROTECTOR,:ROCKYHELMET,:TR63,:WISHINGPIECE,:EVIOLITE,:TR76,:TR75,:RARECANDY,:BOTTLECAP,:PPUP],
  :STEEL=>[:TR31,:TR46,:METALPOWDER,:WISHINGPIECE,:UTILITYUMBRELLA,:METALCOAT,:TR52,:ASSAULTVEST,:TR79,:AMULETCOIN,:TR70,:TR64,:RARECANDY,:BOTTLECAP,:PPUP],
  :WATER=>[:SEAINCENSE,:TR04,:SHELLBELL,:WISHINGPIECE,:TR16,:TR98,:PRISMSCALE,:MYSTICWATER,:PEARLSTRING,:TR45,:TR84,:TR03,:RARECANDY,:BOTTLECAP,:PPUP],
}
CRAMOMATIC_RATIO=[20,30,40,50,60,70,80,90,100,110,120,130,140,150,-1]

def pbCramOMatic
  if Kernel.pbConfirmMessage(_INTL("Combine Items?"))
    Kernel.pbMessage(_INTL("Select the items to be combined.\\1"))
    items=[]
    4.times do
      craft=0
      pbFadeOutIn(99999){
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        craft = screen.pbChooseItemScreen(Proc.new{|item| CRAMOMATIC_ITEMDATA.keys.include?(getConstantName(PBItems,item).to_sym) })
      }
      break if craft==0
      items.push(craft)
      $PokemonBag.pbDeleteItem(craft)
    end
    if items.length<4
      items.each{|item| $PokemonBag.pbStoreItem(item)}
      return
    end
    qty=1
    if items.all?{|item| pbIsApricorn?(item)}
      ratio=[247,247,247,247,10,1,1]
      craft=items[rand(items.length)]
      case craft
      when getID(PBItems,:BLKAPRICORN),getID(PBItems,:BLACKAPRICORN)
        table=[:POKEBALL,:GREATBALL,:DUSKBALL,:LUXURYBALL,:HEAVYBALL,:SAFARIBALL,:SPORTBALL]
      when getID(PBItems,:BLUAPRICORN),getID(PBItems,:BLUEAPRICORN)
        table=[:POKEBALL,:GREATBALL,:DIVEBALL,:NETBALL,:LUREBALL,:SAFARIBALL,:SPORTBALL]
      when getID(PBItems,:GRNAPRICORN),getID(PBItems,:GREENAPRICORN)
        table=[:POKEBALL,:GREATBALL,:ULTRABALL,:NESTBALL,:FRIENDBALL,:SAFARIBALL,:SPORTBALL]
      when getID(PBItems,:PNKAPRICORN),getID(PBItems,:PINKAPRICORN)
        table=[:POKEBALL,:GREATBALL,:ULTRABALL,:HEALBALL,:LOVEBALL,:SAFARIBALL,:SPORTBALL]
      when getID(PBItems,:REDAPRICORN)
        table=[:POKEBALL,:GREATBALL,:ULTRABALL,:REPEATBALL,:LEVELBALL,:SAFARIBALL,:SPORTBALL]
      when getID(PBItems,:WHTAPRICORN),getID(PBItems,:WHITEAPRICORN)
        table=[:POKEBALL,:GREATBALL,:PREMIERBALL,:TIMERBALL,:FASTBALL,:SAFARIBALL,:SPORTBALL]
      when getID(PBItems,:YLWAPRICORN),getID(PBItems,:YELLOWAPRICORN)
        table=[:POKEBALL,:GREATBALL,:ULTRABALL,:QUICKBALL,:MOONBALL,:SAFARIBALL,:SPORTBALL]
      end
      total=0
      ratio.each{|r| total+=r}
      num=rand(total)
      cumtotal=0
      for i in 0...table.length
        cumtotal+=ratio[i]
        if num<cumtotal
          ball=i
          break
        end
      end
      item=getID(PBItems,table[ball])
      qty=(rand(100)==0)? 5 : 1
    elsif isConst?(items[0],PBItems,:TINYMUSHROOM) &&
          isConst?(items[2],PBItems,:TINYMUSHROOM) && 
          isConst?(items[3],PBItems,:TINYMUSHROOM)
      item=getID(PBItems,:BIGMUSHROOM)
    elsif isConst?(items[0],PBItems,:PEARL) &&
          isConst?(items[2],PBItems,:PEARL) && 
          isConst?(items[3],PBItems,:PEARL)
      item=getID(PBItems,:BIGPEARL)
    elsif isConst?(items[0],PBItems,:BIGPEARL) &&
          isConst?(items[2],PBItems,:BIGPEARL) && 
          isConst?(items[3],PBItems,:BIGPEARL)
      item=getID(PBItems,:PEARLSTRING)
    elsif isConst?(items[0],PBItems,:STARDUST) &&
          isConst?(items[2],PBItems,:STARDUST) && 
          isConst?(items[3],PBItems,:STARDUST)
      item=getID(PBItems,:STARPIECE)
    elsif isConst?(items[0],PBItems,:BIGMUSHROOM) &&
          isConst?(items[2],PBItems,:BIGMUSHROOM) && 
          isConst?(items[3],PBItems,:BIGMUSHROOM)
      item=getID(PBItems,:BALMMUSHROOM)
    elsif isConst?(items[0],PBItems,:NUGGET) &&
          isConst?(items[2],PBItems,:NUGGET) && 
          isConst?(items[3],PBItems,:NUGGET)
      item=getID(PBItems,:BIGNUGGET)
    elsif isConst?(items[0],PBItems,:RARECANDY) &&
          isConst?(items[2],PBItems,:RARECANDY) && 
          isConst?(items[3],PBItems,:RARECANDY)
      item=getID(PBItems,:ABILITYCAPSULE)
    elsif isConst?(items[0],PBItems,:BOTTLECAP) &&
          isConst?(items[2],PBItems,:BOTTLECAP) && 
          isConst?(items[3],PBItems,:BOTTLECAP)
      item=getID(PBItems,:GOLDBOTTLECAP)
    elsif isConst?(items[0],PBItems,:ARMORITEORE) &&
          isConst?(items[2],PBItems,:ARMORITEORE) && 
          isConst?(items[3],PBItems,:ARMORITEORE)
      item=getID(PBItems,:PPUP)  
    elsif isConst?(items[0],PBItems,:STARPIECE) &&
          isConst?(items[2],PBItems,:STARPIECE) && 
          isConst?(items[3],PBItems,:STARPIECE)
      item=getID(PBItems,:COMETSHARD)
    else
      type=CRAMOMATIC_ITEMDATA[getConstantName(PBItems,items[0]).to_sym][0]
      value=0
      items.each{|item| 
        value+=CRAMOMATIC_ITEMDATA[getConstantName(PBItems,item).to_sym][1]
      }
      list=CRAMOMATIC_TYPERECIPIES[type]
      index=0
      CRAMOMATIC_RATIO.each_index{|i|
        if CRAMOMATIC_RATIO[i]==-1 || value<=CRAMOMATIC_RATIO[i]
          index=i
          break
        end
      }
      item=list[index]
      if item.is_a?(Array)
        item=item[rand(item.length)]
      end
      item=getID(PBItems,item)
    end
    item=getID(PBItems,:REPEL) if item<=0
    Kernel.pbMessage(_INTL("Combination process complete!\n*BUZZ*\\1"))
    Kernel.pbReceiveItem(item,qty)
  end
end