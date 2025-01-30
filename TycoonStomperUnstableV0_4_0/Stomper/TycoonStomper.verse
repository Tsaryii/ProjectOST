using{/Fortnite.com/Devices}
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}
using {HudSystem}
<#
█▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▀ █▀▄   █▄▄ █▄█   ▀█▀ █▀ ▄▀█ █▀█
█▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ ██▄ █▄▀   █▄█ ░█░   ░█░ ▄█ █▀█ █▀▄

▄▀█ █░░ █░░   █▀█ █ █▀▀ █░█ ▀█▀ █▀   █▀█ █▀▀ █▀ █▀▀ █▀█ █░█ █▀▀ █▀▄
█▀█ █▄▄ █▄▄   █▀▄ █ █▄█ █▀█ ░█░ ▄█   █▀▄ ██▄ ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▄▀

█▀▄ █▀█   █▄░█ █▀█ ▀█▀   █▀ █▀▀ █░░ █░░
█▄▀ █▄█   █░▀█ █▄█ ░█░   ▄█ ██▄ █▄▄ █▄▄
#>

tycoon_stomper <public> := class(creative_device):
    var PlayerStatsMap <public> : [player]?playerstats = map{}
    var UnclaimedBases <public> : []base = array{}

    

    

   

    @editable {ToolTip:=BaseTT} var Bases <public> : []base = array{}

    @editable var Config <public> : log = log{}
    

    #When the game starts, tell the bases to start / initialize
    OnBegin<override>()<suspends>:void=
        spawn. AsyncManageTempStats()
        spawn. ManageBaseClaiming()
        set UnclaimedBases = Bases
        for(I -> Base:Bases):
            Base.OnBegin(I); set Base.Owner = Self

        if:
            Config.Onboarding?
        then:
            OnboardingUI := onboarding_ui{Owner:=Self}
            OnboardingUI.OnBegin(-1)

            


    
            

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
                    if:
                        StatsMap := PlayerStatsMap[Player]?
                    then:
                        StatsMap.OnLeave()
                    if. RemoveTemporaryPlayerStats[Player]
                    GlobalSuperlog("Removed player stats")
        
    GiveTemporaryPlayerStats(P:player)<transacts><decides>:void=
        not PlayerStatsMap[P]?
        set PlayerStatsMap[P] = option{playerstats{Player:=P}}
        GlobalSuperlog("Granted player stats to a player")

    RemoveTemporaryPlayerStats(P:player)<transacts><decides>:void=
        PlayerStatsMap[P]?
        set PlayerStatsMap[P] = false
        GlobalSuperlog("Removed player stats from a player")

    


    ManageBaseClaiming()<suspends>:void={
        Sleep(1.0)
        case(Config.BaseClaimType):

            BaseClaimTypeEnum.Manual => return
            BaseClaimTypeEnum.Fill => ManageBaseFill()
            BaseClaimTypeEnum.Teleport => ManageBaseTeleport()
            
    }
    ManageBaseFill()<suspends>:void=
        for:
            Player:GetPlayspace().GetPlayers()
        do:
            FillRandomBase(Player)
        loop:
            Player := GetPlayspace().PlayerAddedEvent().Await()
            FillRandomBase(Player)
            

    FillRandomBase(Player:player):void=
        if{FreeBase:=UnclaimedBases[GetRandomInt(0, UnclaimedBases.Length-1)]}
        then{FreeBase.OnBought(Player)}

    FillTPRandomBase(Player:player)<suspends>:void=
        if
            {
                FortCharacter := Player.GetFortCharacter[]
                FreeBase:=UnclaimedBases[GetRandomInt(0, UnclaimedBases.Length-1)]
                zoneTranslation := FreeBase.Base_Setup.PurchaseableConfigs.Purchase_Zone.Zone.GetTransform().Translation
                FinalTranslation : vector3 = vector3{X:=zoneTranslation.X, Y:=zoneTranslation.Y, Z:=zoneTranslation.Z+100.0}
            }

            then
            {
                
                FreeBase.OnBought(Player); Sleep(1.0)
                if. FortCharacter.TeleportTo[FinalTranslation, rotation{}]
            }
    
    ManageBaseTeleport()<suspends>:void=
        for:
            Player:GetPlayspace().GetPlayers()
        do:
            FillTPRandomBase(Player)
        loop:
            Player := GetPlayspace().PlayerAddedEvent().Await()
            FillTPRandomBase(Player)


    