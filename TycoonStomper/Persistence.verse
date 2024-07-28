using { /Verse.org/Simulation }
#Defines the player profile data class and the map that stores it
player_profile_data := class<final><persistable>:
    Version:int = 0
    Rebirths:int = 0
    AssociatedCurrencies: [int]int = map{}
    AssociatedUnlocks: []tuple(PurchaseableType, int) = array{}
    Experience : int = 0
 
#Defines the map that stores the player profile data
var PlayerProfileDataMap:weak_map(player, player_profile_data) = map{}

#Creates a new player profile data object
MakePlayerProfileData<constructor>(Src:player_profile_data)<transacts> := player_profile_data:
    Version := Src.Version
    AssociatedCurrencies := Src.AssociatedCurrencies
    Experience := Src.Experience
    AssociatedUnlocks := Src.AssociatedUnlocks
    Rebirths := Src.Rebirths

Rebirth(P:player)<transacts>:void=
    GlobalSuperlog("Rebirting Player")
    if:
        Map := PlayerProfileDataMap[P]
        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            Rebirths := Map.Rebirths + 1

DelidCurrencies(P:player)<transacts><decides>:void=
    var DelidMap: [int]int = map{}
    for{I := 0..100}
    do{set DelidMap[I] = 0}

    if:
        Map := PlayerProfileDataMap[P]
        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            AssociatedCurrencies := DelidMap

DelidUnlocks(P:player)<transacts><decides>:void=
    var DelidMap: []tuple(PurchaseableType, int) = array{}
    if:
        Map := PlayerProfileDataMap[P]
        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            AssociatedUnlocks := DelidMap

#Updates the associated currencies for a player
UpdateAssociatedCurrencies(P:player, CurrencyKey:int, CurrencyValue:int)<transacts>:void=
    if:
        Map := PlayerProfileDataMap[P]
        var PastCurrency : [int]int = Map.AssociatedCurrencies
        set PastCurrency[CurrencyKey] = CurrencyValue
        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            AssociatedCurrencies := PastCurrency


UpdateAssociatedUnlocks(P:player, KeyType:PurchaseableType, Index:int)<transacts>:void=
    if:
        Map := PlayerProfileDataMap[P]
        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            AssociatedUnlocks := Map.AssociatedUnlocks + array{(KeyType, Index)}
            
                


            
UpdateXP(P:player, XP:int)<transacts>:void=
    if:
        Map := PlayerProfileDataMap[P]

        set PlayerProfileDataMap[P] = player_profile_data:
            MakePlayerProfileData<constructor>(Map)
            Experience := XP
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
     
