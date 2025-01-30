using { /Verse.org/Simulation }
using {cc}


#Temp states on a game by game basis
playerstats:=class<final><unique>(Rebirthable):

    var HasClaimedBase : ?base = false
    var Player:player


    OnLeave():void=
        if:
            ClaimedBase := HasClaimedBase?
            ClaimedBase.RootPlayer? = Player
        then:
            ClaimedBase.OnRebirth()
            RemoveRebirth(Player, ClaimedBase.Base_Setup.PersistenceCore)
        else:
            GlobalSuperlog("Failed X2")
        set HasClaimedBase = false

    OnRebirth<override>():void=
        if:
            ClaimedBase := HasClaimedBase?
        then:
            set HasClaimedBase = false

    ClaimBase<public>(Base:base)<transacts><decides>:void=
        not HasClaimedBase?
        GlobalSuperlog("Claiming Base -- Passed not HasClaimedBase? Check")
        set HasClaimedBase = option{Base}



#Defines the player profile data class and the map that stores it
player_profile_data := class<final><persistable>:
    Version:int = 0
    CoreSaves  : [int]core_save = map{}


core_save := class <final><persistable>:
    Rebirths:int = 0
    AssociatedCurrencies: [int]int = map{}
    AssociatedUnlocks: []tuple(PurchaseableType, int) = array{}
    Experience : int = 0

 
#Defines the map that stores the player profile data
var PlayerProfileDataMap:weak_map(player, player_profile_data) = map{}




#Creates a new player profile data object
MakePlayerProfileData<constructor>(Src:player_profile_data)<transacts> := player_profile_data:
    Version := Src.Version+1
    CoreSaves:=Src.CoreSaves

MakeCoreSave<constructor>(Src:core_save)<transacts> := core_save:
    Rebirths:=Src.Rebirths
    AssociatedCurrencies:= Src.AssociatedCurrencies
    AssociatedUnlocks:= Src.AssociatedUnlocks
    Experience := Src.Experience

ChangeCoreSave(Src:[int]core_save, id:int, coresave:core_save)<transacts>:[int]core_save=
    var temp: [int]core_save = Src
    if. set temp[id] = coresave; temp

    

RemoveRebirth(P:player, CoreSaveID:int)<transacts>:void=
    
    GlobalSuperlog("Rebirting Player")
    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]
    then:
        if:
            EstablishedSave := Map.CoreSaves[CoreSaveID]
            
            NewSave := core_save:
                MakeCoreSave<constructor>(EstablishedSave)
                Rebirths:=EstablishedSave.Rebirths-1

            set PlayerProfileDataMap[P] = player_profile_data:
                MakePlayerProfileData<constructor>(Map)
                CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)

            



Rebirth(P:player, CoreSaveID:int)<transacts>:void=
    
    GlobalSuperlog("Rebirting Player")
    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]
    then:
        if:
            EstablishedSave := Map.CoreSaves[CoreSaveID]
            
            NewSave := core_save:
                MakeCoreSave<constructor>(EstablishedSave)
                Rebirths:=EstablishedSave.Rebirths+1

            set PlayerProfileDataMap[P] = player_profile_data:
                MakePlayerProfileData<constructor>(Map)
                CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)

            

DelidCurrencies(P:player, CoreSaveID:int)<transacts><decides>:void=
    var DelidMap: [int]int = map{}
    for{I := 0..100}
    do{set DelidMap[I] = 0}

    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]
    then:
        EstablishedSave := Map.CoreSaves[CoreSaveID]
        NewSave := core_save:
            MakeCoreSave<constructor>(EstablishedSave)
            AssociatedCurrencies := DelidMap


        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)
        

DelidUnlocks(P:player, CoreSaveID:int)<transacts><decides>:void=
    var DelidMap: []tuple(PurchaseableType, int) = array{}
    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]

        EstablishedSave := Map.CoreSaves[CoreSaveID]
        NewSave := core_save:
            MakeCoreSave<constructor>(EstablishedSave)
            AssociatedUnlocks := DelidMap


        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)

#Updates the associated currencies for a player
UpdateAssociatedCurrencies(P:player, CurrencyKey:int, CurrencyValue:int, CoreSaveID:int)<transacts>:void=
    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]
        EstablishedSave := Map.CoreSaves[CoreSaveID]
        

        var PastCurrency : [int]int = Map.CoreSaves[CoreSaveID].AssociatedCurrencies
        set PastCurrency[CurrencyKey] = CurrencyValue

        NewSave := core_save:
            MakeCoreSave<constructor>(EstablishedSave)
            AssociatedCurrencies := PastCurrency

        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)


UpdateAssociatedUnlocks(P:player, KeyType:PurchaseableType, Index:int, CoreSaveID:int)<transacts>:void=
    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]

        EstablishedSave := Map.CoreSaves[CoreSaveID]
        NewSave := core_save:
            MakeCoreSave<constructor>(EstablishedSave)
            AssociatedUnlocks := Map.CoreSaves[CoreSaveID].AssociatedUnlocks + array{(KeyType, Index)}

        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)
            
                


            
UpdateXP(P:player, XP:int, CoreSaveID:int)<transacts>:void=
    if:
        P.IsActive[]
        Map := PlayerProfileDataMap[P]

        EstablishedSave := Map.CoreSaves[CoreSaveID]
        NewSave := core_save:
            MakeCoreSave<constructor>(EstablishedSave)
            Experience := XP

        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            CoreSaves:=ChangeCoreSave(Map.CoreSaves, CoreSaveID, NewSave)
#Gets the associated currencies for a player
GetStats(Agent:agent)<decides><transacts>:player_profile_data=
{
    var PlayerStats : player_profile_data = player_profile_data{}
    if:
        Player := player[Agent]
        PlayerStatsTable := PlayerProfileDataMap[Player]
        set PlayerStats = MakePlayerProfileData(PlayerStatsTable)
    then:
    PlayerStats
}
     
GetCoreStats(Agent:agent, CoreStatsID:int)<decides><transacts>:core_save=
    {
        var PlayerStats : player_profile_data = player_profile_data{}
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerProfileDataMap[Player]
            set PlayerStats = MakePlayerProfileData(PlayerStatsTable)
        then:
        PlayerStats.CoreSaves[CoreStatsID]
    }
         
