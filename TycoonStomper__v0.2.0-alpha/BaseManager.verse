using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {Purchaseables}
using {/Fortnite.com/Teams}
using {Runtimeinstantiables}
using {HudSystem}
using {cc}
using {Stomper}
#Defines what a 'Team' is and how it functions.
base:=class<concrete>(SuperInaugurable, Rebirthable):

    var UniqueID:string = ""

    var selfindex:int = -1

    var Status : ClaimStatus = ClaimStatus.Unclaimed

    #The list of players on the team.
    var Players: []player = array{}

    var Owner:tycoon_stomper = tycoon_stomper{}

    var Rebirthed: event(player) = event(player){}

    var MoneyLeague : money_league = money_league{}

    #The volume device that is used to claim the base.
    @editable var Base_Setup : base_setup = base_setup{}
    

    #The basic props that the base has.
    @editable var BasicProps: []basic_prop_buyable = array{}

    #The collectables that the base has.
    @editable var Collectables: []unique_collectable = array{}

    #The conveyors that the base has.
    @editable var Conveyors: []conveyor_buyable = array{}

    #The currencies that the base uses.
    @editable var Currencies : []currency_config = array{}

    #Dance floors that the base has.
    @editable var DanceFloors: []dancefloor_buyable = array{}

    #The conveyors that the base has.
    @editable var Droppers: []dropper_buyable = array{}

    #The gifts that the base has.
    @editable var Gifts: []unique_giftable = array{}

    #The hitables that the base has.
    @editable var Hitables: []hitable_buyable = array{}

    #Money wheel that the base has.
    @editable var MoneyWheel: []unique_moneywheel = array{}

    #The NPC spawners that the base has.
    @editable var NPCSpawners: []npc_buyable = array{}

    #The shootables that the base has.
    @editable var Shootables: []shootable_buyable = array{}

    #Hud Config
    @editable var UIConfig : []currency_ui_config = array{}

    
    

    


    
    <# 
    The maximum number of players that can be on the team.
    This is useful for games that have a 'base' that players can claim and share resources with each other.
    This kit isn't optimised for >1 players(Hence this not being editable); however, it will fully function and work with multiple players.
    The kit will work with multiple players, money distribution, and all the other features that are included in the kit will be handled by the base.
    Some features will elect to grant money to all players in the base on event; whilst others will grant money to the player that triggered the event.
    #> SizeLimit : int = 1
    

    InitializeAgent(A:agent)<transacts>:void=
        if:
            Player := player[A]
            not PlayerProfileDataMap[Player]
            set PlayerProfileDataMap[Player] = player_profile_data{}
            DelidCurrencies[Player]
        then:
            Owner.SL.Superlog("Inited player profile data")

        #If persistence is disabled then reset the currencies.
        if:
            Player := player[A]
            not Base_Setup.PersistCurrencies?
            DelidCurrencies[Player]
           
        


        
        

    
    OnBegin(IX:int):void=
        Base_Setup.VFX.OnBegin()
        Initialize(Self, IX)
        

    #Waits for a player to enter the base and attempts to claim it.
    AwaitBaseClaim()<suspends>:void=
        Print("== {Base_Setup.Name} Successfully Initialized ==")
        loop:
            Sleep(0.0)
            Agent := Base_Setup.BaseClaimer.AgentEntersEvent.Await()
            InitializeAgent(Agent)
            if:
                AttemptClaimBase[Agent]
                Status = ClaimStatus.Unclaimed
                Player := player[Agent]
                PlayerStats := GetStats[Player]
                AssociatedUnlocks := PlayerStats.AssociatedUnlocks
            then:
                for(I ->IGifts: Gifts){IGifts.InitGiftable(Player)}
                Base_Setup.VFX.OnEvent()
                Owner.SL.Superlog("Player has {PlayerStats.Rebirths} Rebirths")
                
                for(Collectable:Collectables){Collectable.Show(Self)}
                Base_Setup.HudConfig.OnSuccess(Self)
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
                
                
                

                    
            else:
                Base_Setup.HudConfig.OnFail(Self)
                Print("Base is already claimed or size limit was reached (Status: [== Claimed ==]")
            

            
            

    AwaitUIDestroy(UI:currency_ui)<suspends>:void=
        loop:
            Rebirthed.Await()
            UI.Destroy();
    #Attempts to claim the base.
    AttemptClaimBase(A:agent)<transacts><decides>:void=
        Owner.SL.Superlog("=Attempting to claim base=")
        if:
            Players.Length < SizeLimit
            Player := player[A]
        then:
            AddToTeam(Player)
            Print("== Base Successfully Claimed ==")
            

        else:
            set Status = ClaimStatus.Claimed
            Owner.SL.Superlog("Setting status to claimed")


    AwaitRebirth()<suspends>:void=
    {
        loop:
            Interactor := Base_Setup.RebirthButton.InteractedWithEvent.Await()
            if:
                Player := player[Interactor]
            then:
                Rebirthed.Signal(Player)
            OnRebirth()

            
            var ShowButtons: []int = array{}

            for(I  -> ShowButton:ShowButtons):



            
    }

    Foo(Val:int)<suspends>:void={
                
            }

    OnRebirth<override>():void=
        Owner.SL.Superlog("Attempting Rebirth")
        
        for(I ->IBasicProps: BasicProps){IBasicProps.OnRebirth()}
        for(I ->INPCSpawner: NPCSpawners){INPCSpawner.OnRebirth()}
        for(I ->IDropper: Droppers){IDropper.OnRebirth()}
        for(I ->IConveyor: Conveyors){IConveyor.OnRebirth()}
        for(I ->IHitable: Hitables){IHitable.OnRebirth()}
        for(I ->IShootable: Shootables){IShootable.OnRebirth()}
        for(I ->IDancefloors: DanceFloors){IDancefloors.OnRebirth()}
        set Status = ClaimStatus.Unclaimed

        set MoneyLeague = money_league{}

        for:
            Player:Players
            DelidCurrencies[Player]
            DelidUnlocks[Player]
            
        do:
            Rebirth(Player)
            set Players = Players.RemoveAllElements(Player)
            
        set Players = array{}
        if:
            tempid := CreateID[15]
            set UniqueID = tempid
        then:
            Owner.SL.Superlog("Base ID is {UniqueID}")
        return
    #Initializes the base.
    Initialize<override>(Base:base, IX:int):void=
        #Set the base as unclaimed and enable all the Buy Zones again.
        set Status = ClaimStatus.Unclaimed
        set selfindex = IX
       
        #Await for rebirths to be triggered.
        spawn{AwaitRebirth()}


        #Await the base to be claimed.
        spawn{AwaitBaseClaim()}

        if(ID := CreateID[15]){set UniqueID = ID}
        Owner.SL.Superlog("Base ID is {UniqueID}")

        
        Base_Setup.VFX.Initialize()

        #For every purchaseable type in the base, initialize them.
        #Im not doing a multi-line for loop because a for loop can fail if one of the arrays is empty.
        for(I -> ICurrency: Currencies){ICurrency.Initialize(Self)}
        for(I ->IBasicProps: BasicProps){IBasicProps.Initialize(Self, I)}
        for(I ->INPCSpawner: NPCSpawners){INPCSpawner.Initialize(Self, I)}
        for(I ->IDropper: Droppers){IDropper.Initialize(Self, I)}
        for(I ->IConveyor: Conveyors){IConveyor.Initialize(Self, I)}
        for(I ->ICollectable: Collectables){ICollectable.Initialize(Self)}
        for(I ->IHitable: Hitables){IHitable.Initialize(Self, I)}
        for(I ->IShootable: Shootables){IShootable.Initialize(Self, I)}
        for(I ->IGifts: Gifts){IGifts.Initialize(Self)}
        for(I ->IMoneywheel: MoneyWheel){IMoneywheel.Initialize(Self)}
        for(I ->IDancefloors: DanceFloors){IDancefloors.Initialize(Self, I)}

        


        
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
            Owner.SL.Superlog("Player is already on the team or size limit was reached")

    #Checks if a player is on the team and returns the index of the player in the Players list.
    (Player:player).IsOnTeam()<transacts><decides>:int={I := Players.Find[Player]; I}
        
#Defines the status of a base.
ClaimStatus := enum:
    Claimed
    Unclaimed
