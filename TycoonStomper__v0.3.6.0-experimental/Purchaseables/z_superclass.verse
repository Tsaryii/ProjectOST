using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}

#This script is a template for creating purchasable items in the game. 
#It is a parent class for all purchasable items and contains all the necessary methods and properties for a purchasable item.
#It inherits from the Detailable, Hostable,  SuperInaugurable, and Rebirthable interfaces.
#The following are the most important properties and methods:
# - Initialize method -> initializes the item and calls the parent class's Initialize method through the super keyword
# - Host method -> runs async after the item is bought
# - OnBought method -> runs after the item is bought
# - OnGrantInterval method -> grants the player money on an interval

# - Unlock method -> unlocks the item
# - UnlockDependents method -> unlocks all dependents of the item
# - TestAndCommitPurchase method -> checks if the player has enough money along with other requirements before purchasing



# - AwaitAttemptedPurchase method -> awaits the player to enter the purchase zone
# - HideProps method -> hides the props associated with the item
# - ShowProps method -> shows the props associated with the item


purchaseable<public>:=class<abstract>(Detailable, Hostable, SuperInaugurable, Rebirthable, SubHostable, IntegralFX, Gated, StringReturnables):
    var ID <public> : string = ""
    var OnInitalized <public> : event() = event(){}
    var OnInitalizedChild <public> : event() = event(){}
    var MaybeOwner <public> : ?base = false
    var Ptype <public> : PurchaseableType
    var MyIndex:int=-1
    var IsPurchased: PurchasedStatus = PurchasedStatus.NotPurchased
    var InitialStatus: Dependency = Dependency.Unlocked
    var CanLoad: logic = false
    var GlobalOriginProps : [TWC_unique_prop][]origin_prop = map{}
    var DefaultAltClaim<public>:logic=false

    var OnBoughtEvent <public> : event(agent) = event(agent){}
    var SetOwnerEvent <public> : event(base) = event(base){}
    var BegunHosting : event() = event(){}
    var UnlockEvent <public> : event() = event(){}
    var StatusChange <public> : event() = event(){}
    var RebirthedEvent <public> : event() = event(){}

    @editable {ToolTip:=NameTT} var  Name <public>:  string = "My item name here"
    # The name of the item
    
    @editable var  Description <public>: string = "My \nmulti line \nitem description here"
    # The description of the item
    
    @editable var  Price <public>: int = {0}
    # The price of the item
    
    @editable var  ExperiencePointsToAdd  : int = {0}
    # The amount of experience points to add when the item is purchased
    
    @editable {ToolTip:=CurrenySpendTT} var  CurrencyToSpendID  <public>: int = {0}
    # The ID of the currency to spend when purchasing the item
    
    @editable var  CurrencyToReceiveID  <public>: int = {0}
    # The ID of the currency to receive when purchasing the item
    
    @editable var  GrantAmount <public>: int = {0}
    # The amount to grant to the player when the item is purchased
    
    @editable {ToolTip:=GrantIntervalTT} var  GrantInterval : ?float = option{15.0}
    # The interval at which to grant the player the grant amount

    
    @editable {ToolTip:=StartAsTT} var  StartAs <public> : Dependency = Dependency.Unlocked
    # The initial status of the item (locked or unlocked)

    @editable var  Accolade: accolades_device = accolades_device{}
    # The accolade associated with the item
    
    @editable var  OnUnlockCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    # The cinematic sequence to play when the item is unlocked
    
    @editable var  OnPurchaseCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    # The cinematic sequence to play when the item is purchased
    
    @editable {ToolTip:=BypassZoneTT} var  BypassZone <public> : logic = {false}
    # Whether to bypass the purchase zone when buying the item
    
    @editable var  UnlockTheseItems : []purchase_set = array{}
    # The items that should be unlocked when this item is purchased

    @editable var PropsV2 : []TWC_unique_prop = array{}
    # The props associated with the item

    @editable var AnimationConfig <public> : animation_main = animation_main{}
    # The animation configuration for the item
    
    @editable var  HudConfig : hud_main = hud_main{OnFailedMessage := option{"You need [MoneyNeeded] more to purchase [Name]"}; OnSuccessMessage := option{"Succsessfully Purchased [Name]"}}
    # The HUD configuration for the item

    @editable var BillboardConfig : billboard_main = billboard_main{}
    # The billboard configuration for the item
    
    @editable var  ConditionsToBuy : condition = condition{}
    # The conditions that must be met in order to buy the item
    
    @editable var  Purchase_Zone <public> : anyzone_or_atm = anyzone_or_atm{}
    # The purchase zone associated with the item
    
    @editable var  VFX : vfx_main = vfx_main{}
    # The visual effects for the item

    @editable var SFX : sfx_main = sfx_main{}
    # The sound effects for the item
    




    #*********************#
    #  Interface methods  #
    #*********************#    

    OnRebirth<override>():void=
        RebirthedEvent.Signal()
        if(InitialStatus = Dependency.Unlocked){Unlock()}
        if(InitialStatus = Dependency.Locked){Lock()}

        if:
            IsPurchased = PurchasedStatus.Purchased
            
        then:
            set CanLoad = true
            set IsPurchased = PurchasedStatus.NotPurchased
            Purchase_Zone.Enable()
            Purchase_Zone.Show()
            spawn{SubHost()}
        if:
            StartAs = Dependency.Unlocked
            Owner := MaybeOwner?
        then:
            InitializeChildren(Owner, MyIndex)
        else:
            GlobalSuperlog("{Name} is locked. Not initializing children... --->> Awaiting until unlocked.")

    #Prints the item's details
    Detail<override>(Type:string)<transacts>:void=
        GlobalSuperlog("==[{Type}]==")

    #Initializes the item
    Initialize<override>(Hostess:base, I:int):void=
        GlobalSuperlog("Initializing {Name}...")
        VFX.OnBegin(-1)
        SFX.OnBegin(-1)
        BillboardConfig.OnBegin(-1)
        BillboardConfig.Initialize(Self)
        HudConfig.Initialize(Self)
        SetupPropsV2()
        set InitialStatus = StartAs
        set MyIndex = I
        set MaybeOwner = option{Hostess}
        spawn{SubHost()}
        set Purchase_Zone.Origin = Purchase_Zone.Zone.GetTransform().Translation

           
        spawn{Purchase_Zone.AwaitUnlock(Self)}
        
        if:
            X := CreateID[10]
            set ID = X
        else:
            GlobalSuperlog("Couldnt make ID for: {Name};")

        if:
            StartAs = Dependency.Unlocked
        then:
            InitializeChildren(Hostess, I)
            GlobalSuperlog("Initing CHildren for {Name}")
        else:
            GlobalSuperlog("{Name} is locked. Not initializing children... --->> Awaiting until unlocked.")



        


            
                    
    InitializeChildren(Hostess:base, I:int):void=
        set CanLoad = true
        set MaybeOwner = option{Hostess}
        Purchase_Zone.Initialize(Hostess, DefaultAltClaim)
        InitializeFX()
        BillboardConfig.Instantiate()
        spawn{AwaitAttemptedPurchase(Purchase_Zone, Hostess)}
        OnInitalized.Signal()
        SetOwnerEvent.Signal(Hostess)


    ManageHost()<suspends>:void=
        race:
            block:
                Host()
            block:
                RebirthedEvent.Await()


    #Runs after the item is bought
    #This method is meant to be overridden by the child class
    #It runs after the item is bought and is meant to be used for any async code that needs to run after the item is bought
    Host<override>()<suspends>:void


    #Runs async before the item is bought (Ensure you cancel any functions you spawn here after a purchase is made or you'll have a MEMORY LEAK when players rebirth)
    # You can cancel the functions you spawn here by simply racing them with the BegunHosting.Await() event
    # Look at ManagePrePurchaseProps for an example.
    SubHost<override>()<suspends>:void=
        for:
            TWC:PropsV2
        do:
            spawn{ManageTWC(TWC)}
            

    ManageTWC(TWC:TWC_unique_prop)<suspends>:void=
        race:
            sync: 
                ManagePrePurchasePropSet(TWC)
                ManagePostPurchaseSet(TWC)
            RebirthedEvent.Await()

           
    ManagePostPurchaseSet<public>(TWC:TWC_unique_prop)<suspends>:void=
        race:
            block:
                RebirthedEvent.Await()
            block:
                BegunHosting.Await()
                case(TWC.OnPurchaseFunction)
                {
                PurchaseMovementType.Nothing =>
                    return
                PurchaseMovementType.Show =>
                    TWC.Show(AnimationConfig)
                PurchaseMovementType.Hide =>
                    TWC.Hide(AnimationConfig)
                }

                        
    ManagePrePurchasePropSet<public>(TWC:TWC_unique_prop)<suspends>:void=
        TWC.Initialize(Self)
        case(TWC.PrePurchaseFunction)
        {
        PropMovementType.Nothing =>
            return
        PropMovementType.Function_As_Button =>
            var SetTimeOut : float = 1.0
            if:
                Owner := MaybeOwner?
            then{
            race:
                loop:
                    Sleep(0.1)
                    if:
                        TimeOut := UsingTimeout[GetSession()]
                        set SetTimeOut = TimeOut
                    then:
                        GlobalSuperlog("Using Timeout for {SetTimeOut}")
                    if:
                        StartAs = Dependency.Unlocked
                    then:
                        if:
                            IsPurchased = PurchasedStatus.NotPurchased
                        then:
                        
                            spawn. TWC.Show(AnimationConfig)

                            if:
                                Player := Owner.Players[0]
                                MeetsConditions[Owner, ConditionsToBuy, Player, CurrencyToSpendID]
                                CanBuy[Owner, Player, Self]
                                TWC.SwitchToGreen[]
                                
                            else if:
                                TWC.SwitchToRed[]

                                

                        else if:
                            IsPurchased = PurchasedStatus.Purchased
                        then:
                            TWC.Hide(AnimationConfig)
                    else if:
                        StartAs = Dependency.Locked
                    then:
                        Print("Hiding {Name} for being locked")
                        TWC.Hide(AnimationConfig)

                    race:
                        Owner.MoneyGranted.Await()
                        StatusChange.Await()
                        Owner.NewItemBought.Await()
                        BegunHosting.Await()
                        Owner.AttemptedBaseClaim.Await()
                        block:
                            SetOwnerEvent.Await()
                            Sleep(SetTimeOut)
                    
                RebirthedEvent.Await()
            }
        }
            
       
    

    SetupPropsV2<public>():void=
        for:
            TWC:PropsV2
        do:
            if:
                TWC.OriginProps.Length <= 0
            then:
                set TWC.OriginProps = array{}
                for:
                    PropIn:TWC.props
                do:
                    set TWC.OriginProps += array{origin_prop{prop:=PropIn, origin:=PropIn.GetTransform()}}
            else:
                Print("Already has Origin Props")
        return
        
                    
    #Intergral FX System methods
    InitalizeVisuals<override>():void=
        if.  Owner := MaybeOwner?
        then:
            VFX.Initialize(Owner)

    InitalizeAudibles<override>():void=
        if.  Owner := MaybeOwner?
        then:
            SFX.Initialize(Owner)

    InitializeFX<override>():void=
        if.  Owner := MaybeOwner?
        then:
            VFX.Initialize(Owner)  
            SFX.Initialize(Owner)
    
    GetStringParams<override>(MaybeP:?player)<transacts>:[string]string=
        var default : [string]string =  map
        {
            "[Name]"=>Name, 
            "[ID]"=>ID, 
            "[Description]"=>Description, 
            "[Price]"=>"{Price}", 
            "[CurrencyToSpendID]"=>"{CurrencyToSpendID}", 
            "[CurrencyToReceiveID]"=>"{CurrencyToReceiveID}", 
            "[GrantAmount]"=>"{GrantAmount}", 
            "[Ptype]"=>"{Ptype.ToStr()}", 
            "[IsPurchased]"=>"{IsPurchased.ToStr()}",
            "[RebirthsNeeded]"=>"{ConditionsToBuy.MinRebirths}",
            "[MinMoneyCondition]"=>{"{ConditionsToBuy.MinCurrencyAmount}"},
            "[MinExperienceDontion]"=>"{ConditionsToBuy.MinPlayerExperience}"
        }
        if:
            MaybeGrantInterval := GrantInterval?
            set default["[GrantInterval]"] = "{MaybeGrantInterval}"
        if:
            Player := MaybeP?
            Owner := MaybeOwner?
            Stats := PlayerStats := GetCoreStats[Player, Owner.Base_Setup.PersistenceCore]
        then:
            if:
                MoneyNeeded := Price - Stats.AssociatedCurrencies[CurrencyToSpendID]
                set default["[MoneyNeeded]"] = "{MoneyNeeded}"
            if:
                RebirthsLeft := ConditionsToBuy.MinRebirths - Stats.Rebirths
                set default["[RebirthsLeft]"] = "{RebirthsLeft}"


            
        
        return default

        
    #*********************#
    #    Class methods    #
    #*********************#       
    #Unlocks all dependents of the item
    #Returns the number of failures and a boolean indicating if there were any failures
    #The failures are the number of dependents that failed to unlock
    #The boolean indicates if any dependents failed to unlock
    UnlockDependents(Base:base):tuple(int, logic)=
        #Not using the decides / transacts effects so we dont rollback all the other unlocks that were successful.
        var anyfailures:logic=false
        var failures:int=0
        for:
            I -> ItemSet:UnlockTheseItems
        do:
            case(ItemSet.Type):
                PurchaseableType.Undefined =>
                    GlobalSuperlog("Type for 'UnlockTheseItems[{I}]' is undefined")
                PurchaseableType.BasicProp =>
                    if:
                        Basic_Prop := Base.BasicProps[ItemSet.Index]
                    then:
                        Basic_Prop.Unlock()  
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "BasicProp")
                PurchaseableType.NPCBuyable =>
                    if:
                        NPC_Buyable := Base.NPCSpawners[ItemSet.Index]
                    then:
                        NPC_Buyable.Unlock()  
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "NPCBuyable")
                PurchaseableType.Dropper =>
                    if:
                        Dropper := Base.Droppers[ItemSet.Index]
                    then:
                        Dropper.Unlock()  
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "Dropper")
                PurchaseableType.Conveyor =>
                    if:
                        Conveyor := Base.Conveyors[ItemSet.Index]
                    then:
                        Conveyor.Unlock()  
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "Conveyor")
                PurchaseableType.Shootable =>
                    if:
                        Shootable := Base.Shootables[ItemSet.Index]
                    then:
                        Shootable.Unlock()  
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "Shootable")
                PurchaseableType.Hitable =>
                    if:
                        Hitable := Base.Hitables[ItemSet.Index]
                    then:
                        Hitable.Unlock()
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "Hitable")
                PurchaseableType.DanceFloor =>
                    if:
                        DanceFloor := Base.DanceFloors[ItemSet.Index]
                    then:
                        DanceFloor.Unlock()
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "DanceFloor")

                PurchaseableType.Pet =>
                    if:
                        Pet := Base.Pets[ItemSet.Index]
                    then:
                        Pet.Unlock()
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "Pet")

                PurchaseableType.Upgrader =>
                    if:
                        Upgrader := Base.Upgraders[ItemSet.Index]
                    then:
                        Upgrader.Unlock()
                    else:
                        set anyfailures = true; set failures += 1
                        UnlockFailure(ItemSet.Index, "Upgrader")
        (failures, anyfailures)



        
                        





    #Unlocks the item
    #If the item is locked, unlock it else fail
    #If the item is unlocked, play the unlock cinematic and unlock all dependents
    Unlock<override>():void=
        #if the item is locked, unlock it else fail
        if:
            StartAs = Dependency.Locked
            Owner := MaybeOwner?
        then:
            set StartAs = Dependency.Unlocked
            StatusChange.Signal()
            UnlockEvent.Signal()
            InitializeChildren(Owner, MyIndex)
        else:
            return

        
        #If the item is unlocked, play the unlock cinematic and unlock all dependents
        if.  Owner := MaybeOwner?
        then{
        for:
            Player:Owner.Players
        do:
            OnUnlockCinematic.Play(Player)
        return}

    Lock<override>():void=
        #if the item is locked, unlock it else fail
        if:
            StartAs = Dependency.Unlocked
        then:
            set StartAs = Dependency.Locked
            StatusChange.Signal()
        else:
            return


    #Cheks if the player has enough money to purchase the item and other requirements are met before committing the purchase.
    #If the player has enough money, the item is purchased, purchase zone is disabled and the player's stats are updated
    #If the player does not have enough money, the purchase fails
    #If the item is locked, the purchase fails
    TestAndCommitPurchase(Agent:agent)<decides><transacts>:void=
        GlobalSuperlog("== Attempting Purchase == ")
        #Gets the player's stats
        Player:=player[Agent]
        Owner := MaybeOwner?
        Stats := PlayerStats := GetCoreStats[Player, Owner.Base_Setup.PersistenceCore]
        #Gets the player's money associated with the CurrencyToSpendID
        
        AssociatedCurrencies := Stats.AssociatedCurrencies
        #Gets the player's money associated with the CurrencyToReceiveID
        MoneyAssociatedWith_ToSpendID := AssociatedCurrencies[CurrencyToSpendID]
        
        #Checks if the player has enough money to purchase the item
        MoneyAssociatedWith_ToSpendID >= Price

        MeetsConditions[Owner, ConditionsToBuy, Player, CurrencyToSpendID]

        #Checks if the item is unlocked
        StartAs = Dependency.Unlocked

        #If the player has enough money, the item is purchased, purchase zone is disabled and the player's stats are updated
        RemoveMoney(Owner, Player, CurrencyToSpendID, Price)

        #Adds money to the player's CoinDex for the CurrencyToReceiveID
        MoneyAssocatiedWith_ToReceiveID := AssociatedCurrencies[CurrencyToReceiveID]
        
        return
    
    
    #Grants the player money and experience points on an interval
    OnGrantInterval(Agent:agent)<suspends>:void=
        GlobalSuperlog("-Granting Money on Interval")
        if(GA := GrantInterval?;  Owner := MaybeOwner?){if(Owner.MoneyLeague.Update[Owner, CurrencyToReceiveID, GrantAmount, GA]){GlobalSuperlog("Updated MoneyLeague using: {Name}")}}
        loop:
            if:
                GrantInterval? >= 0.0
                Interval := GrantInterval?
                Player : player = player[Agent]
                Owner := MaybeOwner?
                Stats := PlayerStats := GetCoreStats[Player, Owner.Base_Setup.PersistenceCore]
                MoneyToReceive := Stats.AssociatedCurrencies[CurrencyToReceiveID]
                IsPurchased = PurchasedStatus.Purchased
            then:
                Sleep(Interval+0.0)
                GrantMoney(Owner, Player, CurrencyToReceiveID, GrantAmount, BypassZone)   
                
                
            else{GlobalSuperlog("No interval set for: {Name}; or interval is less than 0.0; returning..."); return}
                    
        

        
            

   
    #Awaiting the player to enter the purchase zone. 
    AwaitAttemptedPurchase(PZ:anyzone_or_atm, Hostess:base)<suspends>:void=
        GlobalSuperlog("Awaiting Attempted Purchase for {Name}")
        race:
            block:
                loop:
                    PreventInf();
                    race:
                        block:
                            Agent := Purchase_Zone.PlayerEntersEvent.Await()
                            GlobalSuperlog("Player Enters Event 2")
                        block:
                            Agent := Purchase_Zone.DelayedPlayerEntersEvent.Await()
                            PurchaseSequence(Agent)
            block:
                RebirthedEvent.Await()

    PurchaseSequence(Agent:agent)<suspends>:void=
        if:
            TestAndCommitPurchase[Agent] or DefaultAltClaim?
            Player := player[Agent]
            IsPurchased = PurchasedStatus.NotPurchased
        then:
            OnPurchaseSuccess(Player)
        else if:
            Player := player[Agent]
        then:
            Result := RetryPurchase(Agent)
            if. Result?
            then. OnPurchaseSuccess(Player)
            else:
                Purchase_Zone.Enable(); 
                HudConfig.OnFailurePlayer(Player)

            
    RetryPurchase<public>(Agent:agent)<suspends>:logic=
        RetryPeriod : float = 1.0  # Total time to span retries
        X: int = 5                 # Number of retries

        #Calculate base delay time using exponential backoff
        base_delay : float = RetryPeriod / Pow(2.0,X*1.0 - 1.0) 

        #60.0 / (2.0 ^ 5 - 1.0) = 60.0 / 31.0 = 1.93548387097
        
        #1.93548387097, 3.87096774194, 7.74193548387, 15.4838709677, 30.9677419355
        # Loop for X retries

        # Loop for X retries
        race:
            block:
                for(i := 1..X):
                    # Calculate the delay for this iteration
                    delay_time : float = base_delay * Pow(2.0, (i*1.0-1.0))
                    
                    # Perform the retry action here
                    # Example: RetryAction(agent)
                    # Suspend the function for the calculated delay time
                    Sleep(delay_time)
                    if:
                        TestAndCommitPurchase[Agent]
                        Player := player[Agent]
                        IsPurchased = PurchasedStatus.NotPurchased
                    then:
                        return true
                return false
            block:
                RebirthedEvent.Await()

        return false

    OnPurchaseSuccess(P:player):void=
        if:
            Owner := MaybeOwner?
        then:
            GlobalSuperlog("Success")
            GrantMoney(Owner, P, CurrencyToReceiveID, GrantAmount, BypassZone)
            OnBought(P)
            FirstBought(P)




    #Runs after the item is bought
    OnBought<public>(Agent:agent):void=
        #If the player has enough money, the item is purchased, purchase zone is disabled and the player's stats are updated
        if:
            Player := player[Agent]
            Owner := MaybeOwner?
            CanLoad?
        then:
            set CanLoad = false
            UpdateXP(Player, ExperiencePointsToAdd, Owner.Base_Setup.PersistenceCore)
            Accolade.Award(Player)
            GrantXP(Owner, Player, ExperiencePointsToAdd)
            set IsPurchased = PurchasedStatus.Purchased
            
            Purchase_Zone.OnSuccess(Player, true)
            Purchase_Zone.Disable()
            

            OnBoughtEvent.Signal(Player)
            Owner.NewItemBought .Signal(Self)

            Result := UnlockDependents(Owner)
            if(Result(1)?){GlobalSuperlog("When Unlocking all dependents, ({Result(0)}) failed to unlock")}
            spawn{OnGrantInterval(Agent)}
            spawn{ManageHost()};  BegunHosting.Signal()
            VFX.OnEvent(Player)
            SFX.OnEvent(Player)
            BillboardConfig.Hide()
            UpdateAssociatedUnlocks(Player, Ptype, MyIndex, Owner.Base_Setup.PersistenceCore)
    FirstBought(Agent:agent):void=
        if:
            Player := player[Agent]
        then:
            OnPurchaseCinematic.Play(Player)
            HudConfig.OnSuccessfullPlayer(Player)
            Print("|==|----[{Name} ]----|==|")
            Print("|==|----[ Successfully Purchased ]----|==|")






    
        
    PoorsMansInit<public>():SuperInaugurable=
        Self

#Example of how to create a purchasable item using the purchaseable superclass as a parent class. 
#This class is a template for creating purchasable items in the game.
#It inherits from the purchaseable class and contains all the necessary methods and properties for a purchasable item.


#It contains the following properties and methods:
# - Initialize method -> initializes the item and calls the parent class's Initialize method through the super keyword
# - Host method -> runs after the item is bought
basic_prop_buyable<public>:=class<concrete><final>(purchaseable):

    var Ptype <override> :  PurchaseableType = PurchaseableType.BasicProp

    #Initializes the item
    Initialize<override>(Hostess:base, I:int):void=
        
        #Calls the parent class's Initialize method and waits for it to finish
        (super:)Initialize(Hostess, I)
        
        #Lists out all the properties of the item
        Detail("BasicPropBuyable")


    #Runs after the item is bought
    Host<override>()<suspends>:void=
        #My async code here
        loop:
            Sleep(Inf);


#Example of how to create a second superclass for purchasable items using the purchaseable superclass as a parent class.
#This one is a purchaseable where the fx should react off of the child class' events.
fxpurchaseable<public>:=class<abstract>(purchaseable, ExpandedFX):
    
    @editable var FXMain  <public> :  fx_main = fx_main{}

    TrigEvent : event() = event(){}
    var FirstPlayerOnTeam: ?player = false


    #FX System methods from the ExpandedFX interface

    InitalizeVisuals<override>():void=
        if:
            Owner := MaybeOwner?
        then:
            VFX.Initialize(Owner)
            FXMain.EventBasedVFX.Initialize(Owner)

    InitalizeAudibles<override>():void=
        if:
            Owner := MaybeOwner?
        then:
            SFX.Initialize(Owner)
            FXMain.EventBasedSFX.Initialize(Owner)

    InitializeFX<override>():void=
        if:
            Owner := MaybeOwner?
        then:
            VFX.Initialize(Owner)  
            FXMain.EventBasedVFX.Initialize(Owner)
            FXMain.EventBasedSFX.Initialize(Owner)
            set FirstPlayerOnTeam = Owner.FindFirstPlayerOnTeam()

    PlayFX<override>():void=
        if:
            Player := FirstPlayerOnTeam?
        then:
            VFX.OnEvent(Player)
            SFX.OnEvent(Player)
            FXMain.EventBasedVFX.OnEvent(Player)
            FXMain.EventBasedSFX.OnEvent(Player)

    StopFX<override>():void=
        VFX.EndEvent()
        SFX.EndEvent()
        FXMain.EventBasedVFX.EndEvent()
        FXMain.EventBasedSFX.EndEvent()

    PlayVisuals<override>():void=
        if:
            Player := FirstPlayerOnTeam?
        then:
            VFX.OnEvent(Player)
            FXMain.EventBasedVFX.OnEvent(Player)

    StopVisuals<override>():void=
        VFX.EndEvent()
        FXMain.EventBasedVFX.EndEvent()


    PlayAudibles<override>():void=
        if:
            Player := FirstPlayerOnTeam?
        then:
            SFX.OnEvent(Player)
            FXMain.EventBasedSFX.OnEvent(Player)

    StopAudibles<override>():void=
        SFX.EndEvent()
        FXMain.EventBasedSFX.EndEvent()


    OnEvent()<suspends>:void=
        TrigEvent.Signal()
        if:
            FXMain.RestartWhenActivated?
        then:
            race:
                block: 
                    Sleep(0.1)
                    AsyncPlayFX(FXMain.FXLength)
                block: 
                    TrigEvent.Await()
                    StopFX()
        else:
            race:
                block: 
                    AsyncPlayFX(FXMain.FXLength)
                block: 
                    TrigEvent.Await()
        
    #Custom class methods
    AsyncPlayFX(Time:float)<suspends>:void={PlayFX(); Sleep(Time); StopFX(); return}



        


        

            
    
    






            
                






        
        
        

