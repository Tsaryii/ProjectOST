using{/Fortnite.com/Devices}
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using {cc}

tycoon_stomper <public> := class(creative_device):
    var PlayerStatsMap <public> : [player]?playerstats = map{}

    

   

    @editable var Bases <public> : []base = array{}

    @editable var Config <public> : log = log{}
    

    #When the game starts, tell the bases to start / initialize
    OnBegin<override>()<suspends>:void=
        spawn. AsyncManageTempStats()
        for(I -> Base:Bases):
            Base.OnBegin(I); set Base.Owner = Self
            

    GetPlayerStats<public>(P:player)<transacts><decides>:playerstats=
        return PlayerStatsMap[P]?
            


    AsyncManageTempStats()<suspends>:void=
        Playspace := GetPlayspace()
        for{Player:Playspace.GetPlayers(); GiveTemporaryPlayerStats[Player]}
        do{GlobalSuperlog("Granted player stats to all players in the game")}
        loop:
            race:
                block:
                    Player := Playspace.PlayerAddedEvent().Await()
                    if. GiveTemporaryPlayerStats[Player]
                    GlobalSuperlog("Initialized player stats")
                block:
                    Player := Playspace.PlayerRemovedEvent().Await()
                    if. RemoveTemporaryPlayerStats[Player]
                    GlobalSuperlog("Removed player stats")
        
    GiveTemporaryPlayerStats(P:player)<transacts><decides>:void=
        not PlayerStatsMap[P]?
        set PlayerStatsMap[P] = option{playerstats{}}
        GlobalSuperlog("Granted player stats to a player")

    RemoveTemporaryPlayerStats(P:player)<transacts><decides>:void=
        PlayerStatsMap[P]?
        set PlayerStatsMap[P] = false
        GlobalSuperlog("Removed player stats from a player")

    


        


    