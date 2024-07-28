using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

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


purchaseable<public>:=class<abstract>(Detailable, Hostable, SuperInaugurable, Rebirthable):
    var ID <public> : string = ""
    var OnInitalized <public> : event() = event(){}
    var Owner <public> : base = base{}
    var Ptype <public> : PurchaseableType
    var MyIndex:int=-1
    var IsPurchased: PurchasedStatus = PurchasedStatus.NotPurchased
    var InitialStatus: Dependency = Dependency.Unlocked
    var CanLoad: logic = false

    @editable var  Name <public>:  string = "My item name here"
    @editable var  Description <public>: string = "My \nmulti line \nitem description here"
    @editable var  Price <public>: int = {0}
    @editable var  ExperiencePointsToAdd  : int = {0}
    @editable var  CurrencyToSpendID  <public>: int = {0}
    @editable var  CurrencyToReceiveID  <public>: int = {0}
    @editable var  GrantAmount <public>: int = {0}
    @editable var  GrantInterval : ?float = option{15.0}
    @editable var  PurchaseAnimationStyle : AnimationStyle = AnimationStyle.Grouped
    @editable var  PurchaseAnimation : PAnimation = PAnimation.FadeIn
    @editable var  StartAs: Dependency = Dependency.Unlocked
    @editable var  Accolade: accolades_device = accolades_device{}
    @editable var  OnUnlockCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable var  OnPurchaseCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable var  HudConfig : hud_main = hud_main{}
    @editable var  ConditionsToBuy : condition = condition{}
    @editable var  Purchase_Zone : unique_buy_zone = unique_buy_zone{}
    @editable var  VFX : vfx_main = vfx_main{}
    @editable var  UnlockTheseItems : []purchase_set = array{}
    @editable var  PropsToInitialize : []creative_prop = array{}
    @editable var  PropsToShow : []creative_prop = array{}
    @editable var  PropsToHide : []creative_prop = array{}
    

    #DO VFX NEXT AND LINK THIS TRANSMIT ON PURCHASE TO YOUR PURCHASE ZONES

    #*********************#
    #  Interface methods  #
    #*********************#    

    OnRebirth<override>():void=
        if(InitialStatus = Dependency.Unlocked){Unlock()}
        if(InitialStatus = Dependency.Locked){Lock()}

        if:
            IsPurchased = PurchasedStatus.Purchased
        then:
            set CanLoad = true
            set IsPurchased = PurchasedStatus.NotPurchased
            Purchase_Zone.Enable()
            HideProps(PropsToInitialize)
            HideProps(PropsToShow)
            spawn{ShowProps(PropsToHide)}

    #Prints the item's details
    Detail<override>(Type:string)<transacts>:void=
        GlobalSuperlog("==[{Type}]==")

    #Initializes the item
    Initialize<override>(Hostess:base, I:int):void=
        VFX.OnBegin()
        HideProps(PropsToInitialize)
        GlobalSuperlog("Hiding Props to Initialize...")
        set InitialStatus = StartAs
        set MyIndex = I
        set Owner = Hostess
        if:
            X := CreateID[10]
            set ID = X
        else:
            GlobalSuperlog("Couldnt make ID for: {Name};")

        if:
            StartAs = Dependency.Unlocked
        then:
            InitializeChildren(Hostess, I)
        else:
            GlobalSuperlog("{Name} is locked. Not initializing children... --->> Awaiting until unlocked.")
        
    InitializeChildren(Hostess:base, I:int):void=
        set CanLoad = true
        Purchase_Zone.Initialize(Hostess)
        VFX.Initialize()
        spawn{AwaitAttemptedPurchase(Purchase_Zone, Hostess)}
        OnInitalized.Signal()


        
            

    #Runs after the item is bought
    #This method is meant to be overridden by the child class
    #It runs after the item is bought and is meant to be used for any async code that needs to run after the item is bought
    Host<override>()<suspends>:void
        

        
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
        (failures, anyfailures)



        
                        





    #Unlocks the item
    #If the item is locked, unlock it else fail
    #If the item is unlocked, play the unlock cinematic and unlock all dependents
    Unlock():void=
        #if the item is locked, unlock it else fail
        if:
            StartAs = Dependency.Locked
        then:
            set StartAs = Dependency.Unlocked
            InitializeChildren(Owner, MyIndex)
        else:
            return

        
        #If the item is unlocked, play the unlock cinematic and unlock all dependents
        for:
            Player:Owner.Players
        do:
            OnUnlockCinematic.Play(Player)
        return 

    Lock():void=
        #if the item is locked, unlock it else fail
        if:
            StartAs = Dependency.Unlocked
        then:
            set StartAs = Dependency.Locked
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
        Stats := GetStats[Player]
        #Gets the player's money associated with the CurrencyToSpendID
        
        AssociatedCurrencies := Stats.AssociatedCurrencies
        #Gets the player's money associated with the CurrencyToReceiveID
        MoneyAssociatedWith_ToSpendID := AssociatedCurrencies[CurrencyToSpendID]
       
        
        
        #Checks if the player has enough money to purchase the item
        MoneyAssociatedWith_ToSpendID >= Price

        MeetsConditions[ConditionsToBuy, Player, CurrencyToSpendID]

        #Checks if the item is unlocked
        StartAs = Dependency.Unlocked

        #If the player has enough money, the item is purchased, purchase zone is disabled and the player's stats are updated
        RemoveMoney(Owner, Player, CurrencyToSpendID, Price)

        #Adds money to the player's CoinDex for the CurrencyToReceiveID
        MoneyAssocatiedWith_ToReceiveID := AssociatedCurrencies[CurrencyToReceiveID]
        GrantMoney(Owner, Player, CurrencyToReceiveID, GrantAmount)
        return
    
    
    #Grants the player money and experience points on an interval
    OnGrantInterval(Agent:agent)<suspends>:void=
        GlobalSuperlog("-Granting Money on Interval")
        if(GA := GrantInterval?){if(Owner.MoneyLeague.Update[Owner, CurrencyToReceiveID, GrantAmount, GA]){GlobalSuperlog("Updated MoneyLeague using: {Name}")}}
        loop:
            if:
                GrantInterval? >= 0.0
                Interval := GrantInterval?
                Player : player = player[Agent]
                Stats := GetStats[Player]
                MoneyToReceive := Stats.AssociatedCurrencies[CurrencyToReceiveID]
                IsPurchased = PurchasedStatus.Purchased
            then:
                GrantMoney(Owner, Player, CurrencyToReceiveID, GrantAmount)   
                Sleep(Interval+0.0)
                
            else{Print("No interval set for: {Name}; or interval is less than 0.0; returning..."); return}
                    
        

        
            
        
    #Defines the prop's Z coord for every PAnimation type: which is where it will be held stationary.
    var GranualarDist: float = 1500.0
   
    #Awaiting the player to enter the purchase zone. 
    AwaitAttemptedPurchase(PZ:unique_buy_zone, Hostess:base)<suspends>:void=
        loop:
            Sleep(0.0)
            Agent := Purchase_Zone.PlayerEntersEvent.Await()
            if:
                TestAndCommitPurchase[Agent]
                Player := player[Agent]
                IsPurchased = PurchasedStatus.NotPurchased
            then:
                OnBought(Player)
                FirstBought(Player)

            else{Purchase_Zone.Enable();  HudConfig.OnFail(Owner); Print("Failed to purchase {Name}");}

    #Runs after the item is bought
    OnBought<public>(Agent:agent):void=
        #If the player has enough money, the item is purchased, purchase zone is disabled and the player's stats are updated
        if:
            Player := player[Agent]
            CanLoad?
        then:
            set CanLoad = false
            UpdateXP(Player, ExperiencePointsToAdd)
            Accolade.Award(Player)
            GrantXP(Owner, Player, ExperiencePointsToAdd)
            set IsPurchased = PurchasedStatus.Purchased
            #Disables the purchase zone
            HideProps(PropsToHide)
            Purchase_Zone.Disable()
            
            Result := UnlockDependents(Owner)
            if(Result(1)?){Print("When Unlocking all dependents, ({Result(0)}) failed to unlock")}
            spawn{OnGrantInterval(Agent)}
            spawn{ShowProps(PropsToInitialize+PropsToShow)}
            spawn{Host()}
            VFX.OnEvent()
            
            #triggers the purchase zone's success event
            for{Trigger:Purchase_Zone.TransmitToOnSuccess} 
            do{Trigger.Trigger(Player)};
            
            UpdateAssociatedUnlocks(Player, Ptype, MyIndex)
    FirstBought(Agent:agent):void=
        if:
            Player := player[Agent]
        then:
            OnPurchaseCinematic.Play(Player)
            HudConfig.OnSuccess(Owner)
            Print("|==|----[{Name} ]----|==|")
            Print("|==|----[ Successfully Purchased ]----|==|")





    #Defines the arguements for every PAnimation type
    var PropAlterations:int=0

    #Hides the props associated with the item
    #The props are then moved to a location below the player with a specified animation speed
    HideProps(PropsToAlter:[]creative_prop)<transacts>:void=
        set PropAlterations -= 1
        for(I -> Prop:PropsToAlter){
        Prop.Hide()
        PT := Prop.GetTransform().Translation
        PR := Prop.GetTransform().Rotation
        PL := vector3{X:=PT.X, Y:=PT.Y, Z:=PT.Z+GranualarDist}
            if(Prop.TeleportTo[PL, PR]){}
        }
        return
    #Shows the props associated with the item
    ShowProps(PropsToAlter:[]creative_prop)<suspends>:void=
        set PropAlterations += 1
        for(I -> Prop:PropsToAlter)
        {
            Prop.Show()
            PT := Prop.GetTransform().Translation
            PR := Prop.GetTransform().Rotation
            PL := vector3{X:=PT.X, Y:=PT.Y, Z:=PT.Z-GranualarDist}

            #Props are moved as if they were one solid object (Grouped)
            #This results in a style similar to a whole object being placed.


            case(PurchaseAnimationStyle):
                AnimationStyle.Grouped =>
                    spawn{SpawnedMovement(Prop, PL, PR, GetSpeed(PurchaseAnimation))}
                
                #Does the same as the grouped style but for each prop individually one by one 
                #This results in a style similar to legos being built

                AnimationStyle.LegoLike =>
                    Prop.MoveTo(PL, PR, GetSpeed(PurchaseAnimation)/1.75)

                AnimationStyle.LegoLike5x =>
                    Prop.MoveTo(PL, PR, GetSpeed(PurchaseAnimation)/7.0)

                        
        }
        return
    GetSpeed(Anim:PAnimation):float=
        case(Anim):
            PAnimation.SlowFadeIn => 
                return 1.25
            PAnimation.FadeIn =>
                return 1.0
            PAnimation.FastFadeIn =>
                return 0.75

    SpawnedMovement(Prop:creative_prop, PL:vector3, PR:rotation, Speed:float)<suspends>:void=
        Prop.MoveTo(PL, PR, Speed)
    
        

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
            
    
    






            
                






        
        
        

