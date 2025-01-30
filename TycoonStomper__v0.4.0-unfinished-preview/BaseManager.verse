using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {Purchaseables}
using {/Fortnite.com/Teams}
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Runtimeinstantiables}
using {HudSystem}
using {cc}
using {Stomper}
#Defines what a 'Team' is and how it functions.
base<public>:=class<concrete><unique>(SuperInaugurable, Rebirthable, Runtime, StringReturnables, creative_device):

    var UniqueID:string = ""

    var selfindex:int = -1

    var Status : ClaimStatus = ClaimStatus.Unclaimed

    #The list of players on the team.
    var Players: []player = array{}

    var RootPlayer : ?player = false

    var Owner:tycoon_stomper = tycoon_stomper{}

    var Rebirthed: event(player) = event(player){}

    var MoneyLeague : money_league = money_league{}

    var MoneyGranted : event(tuple(player, int, int)) = event(tuple(player, int, int)){}

    var NewItemBought : event(purchaseable) = event(purchaseable){}

    var CFR : ClaimFauilreReason = ClaimFauilreReason.TooManyPlayers


    @editable var LeaveButton : button_device = button_device{}

    #The volume device that is used to claim the base.
    @editable var Base_Setup : base_setup = base_setup{}
    

    #The basic props that the base has.
    @editable var BasicProps: []basic_prop_buyable = array{}

    #The collectables that the base has.
    @editable var Collectables: []unique_collectable = array{}

    #The conveyors that the base has.
    @editable var Conveyors: []purchaseable_conveyor = array{}

    #The currencies that the base uses.
    @editable var Currencies : []currency_config = array{}

    #Dance floors that the base has.
    @editable var DanceFloors: []dancefloor_buyable = array{}

    #The conveyors that the base has.
    @editable var Droppers: []purchaseable_dropper = array{}

    #The gifts that the base has.
    @editable var Gifts: []unique_giftable = array{}

    #The hitables that the base has.
    @editable var Hitables: []hitable_buyable = array{}

    #Money wheel that the base has.
    @editable var MoneyWheel: []unique_moneywheel = array{}

    #The NPC spawners that the base has.
    @editable var NPCSpawners: []npc_buyable = array{}

    #Pets that the base has.
    @editable var Pets: []pet = array{}

    #The shootables that the base has.
    @editable var Shootables: []shootable_buyable = array{}

    #
    @editable var Upgraders: []purchaseable_upgrader = array{}

    #Hud Config
    @editable var UIConfig : []currency_ui_config = array{}


    #Player to pet map
    var PlayerToPetMap : [player]tuple(pet, logic) = map{}


    #Base Claim
    var AttemptedBaseClaim : event() = event(){}

    petmaxreached : event(player) = event(player){}
    


    #If you add a new purchaseable include it in this list for it to be initialized by this base.
    GetPurchaseArray():[][]purchaseable=
        array
        {
            BasicProps, 
            NPCSpawners, 
            Droppers, 
            Conveyors, 
            Upgraders, 
            Hitables, 
            Shootables, 
            DanceFloors, 
            Pets
        }

        
    


    
    <# 
    The maximum number of players that can be on the team.
    This is useful for games that have a 'base' that players can claim and share resources with each other.
    This kit isn't optimised for >1 players(Hence this not being editable); however, it will techincally function and work with multiple players.
    The kit will work with multiple players, money distribution, and all the other features that are included in the kit will be handled by the base.
    Some features will elect to grant money to all players in the base on event; whilst others will grant money to the player that triggered the event.
    I do not recommend changing this unless you know what you're doing.
    #> SizeLimit : int = 1
    

    InitializeAgent(A:agent)<transacts>:void=
        if:
            Player := player[A]
            not PlayerProfileDataMap[Player]
            set PlayerProfileDataMap[Player] = player_profile_data{}
        then:
            Owner.Config.Superlog("Inited player profile data")
            for:
                X := 0..100
                PlayerData := GetStats[Player]
            do:
                Source := player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerData)
                    CoreSaves:=ChangeCoreSave(PlayerData.CoreSaves, X, core_save{})
                if. set PlayerProfileDataMap[Player] = Source
                if. DelidCurrencies[Player, Base_Setup.PersistenceCore]
                


        #If persistence is disabled then reset the currencies.
        if:
            Player := player[A]
            not Base_Setup.PersistCurrencies?
            DelidCurrencies[Player, Base_Setup.PersistenceCore]

        if:
            Player := player[A]
        then:
            if(set PlayerToPetMap[Player] = (pet{}, false)){}
           
        


        
        

    
    OnBegin<override>(IX:int):void=
        Base_Setup.OnBegin(Self, -1)
        Initialize(Self, IX)

        
    OnBought(Agent:agent):void=
        InitializeAgent(Agent)
            Print("Attempting to claim base")
            Base_Setup.BillBoardConfig.Instantiate()
            if:
                AttemptClaimBase[Agent]
                Status = ClaimStatus.Unclaimed
                Player := player[Agent]
                TempStats := Owner.GetPlayerStats[Player]
                TempStats.ClaimBase[Self]
                PlayerStats := GetCoreStats[Player, Base_Setup.PersistenceCore]
                AssociatedUnlocks := PlayerStats.AssociatedUnlocks
            then:
                if:
                    not RootPlayer?
                then:
                    set RootPlayer = option{Player}
                set Owner.UnclaimedBases = Owner.UnclaimedBases.RemoveAllElements(Self)
                Base_Setup.PurchaseableConfigs.Purchase_Zone.OnSuccess(Player, false)
                for(I ->IGifts: Gifts){IGifts.InitGiftable(Player)}
                Base_Setup.VFX.OnEvent(Player)
                Owner.Config.Superlog("Player has {PlayerStats.Rebirths} Rebirths")
                
                for(Collectable:Collectables){Collectable.Show(Self)}
                Base_Setup.HudConfig.Initialize(Self)
                Base_Setup.HudConfig.OnSuccessfullPlayer(Player)
                if:
                    RebirthHud := Base_Setup.RebirthConfig.RebirthHud?
                then:
                    set UIConfig += array{RebirthHud}
                UI := currency_ui{Player:=Player,  Configs:=UIConfig, owner:=Self}
                UI.Create()
                spawn{AwaitUIDestroy(UI)}
                if:
                    Base_Setup.PersistUnlocks?
                then:
                    for:
                        AUnoock:AssociatedUnlocks
                    do:
                        Load(Self, AUnoock(0), AUnoock(1))
                else if:
                    DelidUnlocks[Player, Base_Setup.PersistenceCore]
                
                if:
                    Players.Length < SizeLimit
                then:
                    GlobalSuperlog("Still in the size limit")
                else:
                    Base_Setup.PurchaseableConfigs.Purchase_Zone.Hide(true)
                    Base_Setup.BillBoardConfig.Hide()

                AttemptedBaseClaim.Signal()


                    
                
                

                    
            else if:
                Player := player[Agent]
            then:
                if:
                    not AttemptClaimBase[Player]
                then:
                    set CFR = ClaimFauilreReason.TooManyPlayers
                else if:
                    TempStats := Owner.GetPlayerStats[Player]
                    not TempStats.ClaimBase[Self]
                then:
                    set CFR = ClaimFauilreReason.AlreadyOwnsBase


                
                Base_Setup.HudConfig.OnFailurePlayer(Player)
                Print("Base is already claimed or size limit was reached (Status: [== {CFR.ToStr()} ==]")

    #Waits for a player to enter the base and attempts to claim it.
    AwaitBaseClaim(IX:int)<suspends>:void=
        Print("== {Base_Setup.Name} Successfully Initialized ==")
        loop:
            PreventInf();
            Agent := Base_Setup.PurchaseableConfigs.OnBoughtEvent.Await(); GlobalSuperlog("ON BOUGHT EVENT")
            OnBought(Agent)
            
            

            
            

    AwaitUIDestroy(UI:currency_ui)<suspends>:void=
        loop:
            Rebirthed.Await()
            UI.Destroy();
    #Attempts to claim the base.
    AttemptClaimBase(A:agent)<transacts><decides>:void=
        Owner.Config.Superlog("=Attempting to claim base=")
        if:
            Players.Length < SizeLimit
            Player := player[A]
        then:
            AddToTeam(Player)
            Print("== Base Successfully Claimed ==")
            

        else:
            set Status = ClaimStatus.Claimed
            Owner.Config.Superlog("Setting status to claimed")


    AwaitRebirth()<suspends>:void=
    {
        Base_Setup.RebirthConfig.HudConfig.Initialize(Self)
        loop:
            Interactor := Base_Setup.RebirthConfig.RebirthButton.InteractedWithEvent.Await()
            if:
                Player := player[Interactor]
                PlayerStats := GetCoreStats[Player, Base_Setup.PersistenceCore]
                Rebirths := PlayerStats.Rebirths
                RebirthCurrencyValue := PlayerStats.AssociatedCurrencies[Base_Setup.RebirthConfig.RebirthCostCurrencyID]
                RebirthCostAmount := GetRebirthCostAmount[Self, Rebirths]
                RebirthCurrencyValue >= RebirthCostAmount
            then:
                Rebirthed.Signal(Player)
                OnRebirth()
            else if:
                Player := player[Interactor]
            then:
                Base_Setup.RebirthConfig.HudConfig.OnFailurePlayer(Player)
            



            
    }

    

    OnRebirth<override>():void=
        Owner.Config.Superlog("Attempting Rebirth")

        (GetPurchaseArray()).RebirthList(Self)


        Base_Setup.PurchaseableConfigs.OnRebirth()
        set Status = ClaimStatus.Unclaimed
        Base_Setup.PurchaseableConfigs.Purchase_Zone.Show()
        set MoneyLeague = money_league{}

        for:
            Player:Players
            DelidCurrencies[Player, Base_Setup.PersistenceCore]
            DelidUnlocks[Player, Base_Setup.PersistenceCore]
            TempStats := Owner.GetPlayerStats[Player]
            
        do:
            TempStats.OnRebirth()
            Rebirth(Player, Base_Setup.PersistenceCore)
            Base_Setup.RebirthConfig.HudConfig.OnSuccessfullPlayer(Player)
            Base_Setup.RebirthConfig.RebirthAccolade.Award(Player)
            set Players = Players.RemoveAllElements(Player)
            
        set Players = array{}
        set RootPlayer = false
        set Owner.UnclaimedBases += array{Self}
        if:
            tempid := CreateID[15]
            set UniqueID = tempid
        then:
            Owner.Config.Superlog("Base ID is {UniqueID}")


        return


    AwaitOnLeave()<suspends>:void=
        loop:
            Agent := LeaveButton.InteractedWithEvent.Await()
            if:
                Player := player[Agent]
                StatsMap := Owner.PlayerStatsMap[Player]?
                Players.Find[Player]
            then:
                StatsMap.OnLeave()

    #Initializes the base.
    Initialize<override>(Base:base, IX:int):void=
        #Set the base as unclaimed and enable all the Buy Zones again.
        set Status = ClaimStatus.Unclaimed
        set selfindex = IX
       

        spawn{AwaitOnLeave()}

        #Await for rebirths to be triggered.
        spawn{AwaitRebirth()}

        #Await for a player to enter the base and attempt to claim it.
        spawn{AwaitBaseClaim(IX)}

        if(ID := CreateID[15]){set UniqueID = ID}
        Owner.Config.Superlog("Base ID is {UniqueID}")

        
        Base_Setup.VFX.Initialize(Self)
        Base_Setup.SFX.Initialize(Self)
        Base_Setup.Initialize(Self)
        
       

        #For every purchaseable type in the base, initialize them.
        #Im not doing a multi-line for loop because a for loop can fail if one of the arrays is empty.
        for(I -> ICurrency: Currencies){ICurrency.Initialize(Self)}
        for(I ->ICollectable: Collectables){ICollectable.Initialize(Self)}
        for(I ->IGifts: Gifts){IGifts.Initialize(Self)}
        for(I ->IMoneywheel: MoneyWheel){IMoneywheel.Initialize(Self)}

        <#>
            New system after I talked to an epic employee and they actually fixed the issue 
            where you couldn't have an array of arrays of child classes even though they all shared a parent superclass.
            SOO NICHE but insane they did it 🙏🙏🙏 <3 Epic Games
        (GetPurchaseArray()).InitList(Self)

   



        

        


        
    #Returns the root player value for every player on the team as an array.
    #Adds a player to the team, if they aren't already on the Players list and the SizeLimit wont exceed.
    AddToTeam(Player:player)<transacts>:void=
        if:
            not Player.IsOnTeam[]
            Players.Length < SizeLimit
        then:
            set Players += array{Player}
            TC := Owner.GetPlayspace().GetTeamCollection()
            Teams := TC.GetTeams()
            if(TC.AddToTeam[Player, Teams[Base_Setup.TeamToAddTo]]){}
        else:
            Owner.Config.Superlog("Player is already on the team or size limit was reached")

    #Checks if a player is on the team and returns the index of the player in the Players list.
    (Player:player).IsOnTeam()<transacts><decides>:int={I := Players.Find[Player]; I}
        

    FindFirstPlayerOnTeam():?player={
        if: 
            Player := Players[0]
        then:
            option{Player}
        else:
            false
        }


        GetStringParams<override>(P:?player)<transacts>:[string]string=
            return map
            {
                "[Name]"=>Base_Setup.Name, 
                "[ID]"=>UniqueID, 
                "[Players.Length]"=>"{Players.Length}", 
                "SizeLimit"=>"{SizeLimit}", 
                "[Status]"=>"{Status.ToStr()}",
                "[FailureReason]"=>"{CFR.ToStr()}"
            }   
           


