using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {Purchaseables}
using {/Fortnite.com/Teams}
using {Runtimeinstantiables}
using {HudSystem}
using {cc}
using {Stomper}
#Defines what a 'Team' is and how it functions.
base<public>:=class<concrete>(SuperInaugurable, Rebirthable, Runtime, StringReturnables):

    var UniqueID:string = ""

    var selfindex:int = -1

    var Status : ClaimStatus = ClaimStatus.Unclaimed

    #The list of players on the team.
    var Players: []player = array{}

    var Owner:tycoon_stomper = tycoon_stomper{}

    var Rebirthed: event(player) = event(player){}

    var MoneyLeague : money_league = money_league{}

    var MoneyGranted : event(tuple(player, int, int)) = event(tuple(player, int, int)){}

    var NewItemBought : event(purchaseable) = event(purchaseable){}

    var CFR : ClaimFauilreReason = ClaimFauilreReason.TooManyPlayers

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
            DelidCurrencies[Player]
        then:
            Owner.Config.Superlog("Inited player profile data")

        #If persistence is disabled then reset the currencies.
        if:
            Player := player[A]
            not Base_Setup.PersistCurrencies?
            DelidCurrencies[Player]

        if:
            Player := player[A]
        then:
            if(set PlayerToPetMap[Player] = (pet{}, false)){}
           
        


        
        

    
    OnBegin<override>(IX:int):void=
        Base_Setup.OnBegin(Self, -1)
        Initialize(Self, IX)

        

    #Waits for a player to enter the base and attempts to claim it.
    AwaitBaseClaim(IX:int)<suspends>:void=
        Print("== {Base_Setup.Name} Successfully Initialized ==")
        loop:
            PreventInf();
            Agent := Base_Setup.PurchaseableConfigs.OnBoughtEvent.Await(); Print("ON BOUGHT EVENT")
            InitializeAgent(Agent)
            Print("Attempting to claim base")
            Base_Setup.BillBoardConfig.Instantiate()
            if:
                AttemptClaimBase[Agent]
                Status = ClaimStatus.Unclaimed
                Player := player[Agent]
                TempStats := Owner.GetPlayerStats[Player]
                TempStats.ClaimBase[]
                PlayerStats := GetStats[Player]
                AssociatedUnlocks := PlayerStats.AssociatedUnlocks
            then:
                Base_Setup.PurchaseableConfigs.Purchase_Zone.OnSuccess(Player, false)
                for(I ->IGifts: Gifts){IGifts.InitGiftable(Player)}
                Base_Setup.VFX.OnEvent(Player)
                Owner.Config.Superlog("Player has {PlayerStats.Rebirths} Rebirths")
                
                for(Collectable:Collectables){Collectable.Show(Self)}
                Base_Setup.HudConfig.Initialize(Self)
                Base_Setup.HudConfig.OnSuccessfullPlayer(Player)
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
                    DelidUnlocks[Player]
                
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
                    not TempStats.ClaimBase[]
                then:
                    set CFR = ClaimFauilreReason.AlreadyOwnsBase


                
                Base_Setup.HudConfig.OnFailurePlayer(Player)
                Print("Base is already claimed or size limit was reached (Status: [== {CFR.ToStr()} ==]")
            

            
            

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
                PlayerStats := GetStats[Player]
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
        
        for(I ->IBasicProps: BasicProps){IBasicProps.OnRebirth()}
        for(I ->INPCSpawner: NPCSpawners){INPCSpawner.OnRebirth()}
        for(I ->IDropper: Droppers){IDropper.OnRebirth()}
        for(I ->IConveyor: Conveyors){IConveyor.OnRebirth()}
        for(I ->Upgrader: Upgraders){Upgrader.OnRebirth()}
        for(I ->IHitable: Hitables){IHitable.OnRebirth()}
        for(I ->IShootable: Shootables){IShootable.OnRebirth()}
        for(I ->IDancefloors: DanceFloors){IDancefloors.OnRebirth()}
        for(I ->Pet: Pets){Pet.OnRebirth()}


        Base_Setup.PurchaseableConfigs.OnRebirth()
        set Status = ClaimStatus.Unclaimed
        Base_Setup.PurchaseableConfigs.Purchase_Zone.Show()
        set MoneyLeague = money_league{}

        for:
            Player:Players
            DelidCurrencies[Player]
            DelidUnlocks[Player]
            TempStats := Owner.GetPlayerStats[Player]
            
        do:
            TempStats.OnRebirth()
            Rebirth(Player)
            Base_Setup.RebirthConfig.HudConfig.OnSuccessfullPlayer(Player)
            Base_Setup.RebirthConfig.RebirthAccolade.Award(Player)
            set Players = Players.RemoveAllElements(Player)
            
        set Players = array{}
        if:
            tempid := CreateID[15]
            set UniqueID = tempid
        then:
            Owner.Config.Superlog("Base ID is {UniqueID}")
        return
    #Initializes the base.
    Initialize<override>(Base:base, IX:int):void=
        #Set the base as unclaimed and enable all the Buy Zones again.
        set Status = ClaimStatus.Unclaimed
        set selfindex = IX
       
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

        ().InitList(Self)


        

        


        
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
           


