using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}

#███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
#██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
#█████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
#██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
#██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
#╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


#Change this to true to enable the global superlog system
#The global superlog system will print all superlogs to the console
#Super logs are for almost everything so this will clutter the console
#This is useful for mass debugging purposes otherwise keep it off
UseGlobalSuperLog: logic = false

GlobalSuperlog(I:string)<transacts>:void={if(UseGlobalSuperLog?){Print("{I}")}}

CreateID<public>(Length:int)<decides><transacts>:string={
        Coords:string=("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        ID := for:
            I := 0..Length
            R:=GetRandomInt(0,35)
        do{Coords[R]}; ID   
}
GlobalizedDetailing(P:purchaseable, Name:string):void=
    Print("\n == {Name} == \n {P.Name} | {P.ID}, \n Description: {P.Description}, \n Price: {P.Price}, \n CurrencyToSpendID: {P.CurrencyToSpendID}, \n CurrencyToReceiveID: {P.CurrencyToReceiveID}, \n GrantAmount: {P.GrantAmount},")
#Shows a localized message to the player using the HUD message device 
(HM:hud_message_device).StringShow(Message:string, Agent:agent):void={HM.SetText(S2M(Message)); HM.Show(Agent)}

#Localizes a string to the player's language by converting the string to a message
S2M<localizes>(s:string)<computes>:message="{s}"




#Grant money to a player
GrantMoney(Base:base, Player:player, GrantID:int, Amount:int)<transacts>:void=
    
        #If the player is found in the base's player list
        if:
            Base.Players.Find[Player]
            Rebirths := GetStats[Player].Rebirths
            CurrentValue := GetStats[Player].AssociatedCurrencies[GrantID]
            #Example with a rebirth multiplier of 1.5 and 100 as the base amount
            #((1.5^0) * 100) = 100
            #((1.5^1) * 100) = 150
            #((1.5^2) * 100) = 225
            #((1.5^3) * 100) = 337.5
            AmountToGrant := GetRebirthAmount[Base, Rebirths, Amount]
        then:
            #If the currency does not have the zone, then update the associated currencies instantly
            if(not HasZone[Base, GrantID]):
                
                UpdateAssociatedCurrencies(Player, GrantID, AmountToGrant+CurrentValue)

            
            #if the user opted to have a zone, then add the amount to the currency's claimable amount
            else if:
                Currency := GetCurrencyConfig[Base, GrantID]
            then:
                Currency.AddAwaitableCash(AmountToGrant)

BypassedGrantMoney(Base:base, Player:player, GrantID:int, Amount:int)<transacts>:void=
    
    #If the player is found in the base's player list
    if:
        Base.Players.Find[Player]
        Rebirths := GetStats[Player].Rebirths
        CurrentValue := GetStats[Player].AssociatedCurrencies[GrantID]
        #Example with a rebirth multiplier of 1.5 and 100 as the base amount
        #((1.5^0) * 100) = 100
        #((1.5^1) * 100) = 150
        #((1.5^2) * 100) = 225
        #((1.5^3) * 100) = 337.5
        AmountToGrant := GetRebirthAmount[Base, Rebirths, Amount]
    then:
            UpdateAssociatedCurrencies(Player, GrantID, AmountToGrant+CurrentValue)

        


RemoveMoney(Base:base, Player:player, GrantID:int, Amount:int)<transacts>:void=
    if:
        Base.Players.Find[Player]
        CurrentValue := GetStats[Player].AssociatedCurrencies[GrantID]
    then:
        #If the currency does not have the zone, then update the associated currencies instantly
            UpdateAssociatedCurrencies(Player, GrantID, CurrentValue-Amount)

        


GetRebirthAmount(Base:base, Rebirths:int, Amount:int)<decides><transacts>:int=
    return Round[(Pow(Base.Base_Setup.RebirthCashMultiplier, Rebirths*1.0) * Amount)]

GrantXP(Base:base, Player:player, Amount:int)<transacts>:void={}
    
condition:=struct<concrete>():
    @editable MinCurrencyAmount: int = 0
    @editable MinPlayerExperience: int = 0

GetConveyorConfig(Base:base, ID:int)<decides><transacts>:unique_conveyor=
    {
        Prim := for:
            I -> C:Base.Conveyors
            I = ID
        do:
            C.ConveyorConfig
        Prim[0]
    }
#Returns the currency config of a bases currency ID
GetCurrencyConfig(Base:base, CurrencyID:int)<decides><transacts>:currency_config=
    {
        Prim := for:
            I -> C:Base.Currencies
            I = CurrencyID
        do:
            C
        Prim[0]
    }

MeetsConditions(Condition:condition, Player:player, CurrencyID:int)<decides><transacts>:void=
        Stats := GetStats[Player]
        Money := Stats.AssociatedCurrencies[CurrencyID]
        Experience := Stats.Experience

        Money >= Condition.MinCurrencyAmount
        Experience >= Condition.MinPlayerExperience
        return
        


#Returns the currency ID of a base specific currency config
GetCurrencyID(Base:base, Currency:currency_config)<decides><transacts>:int=
    {
        Prim := for:
            I -> C:Base.Currencies
            C = Currency
        do:
            I
        Prim[0]
    }


#Checks if a currency has a zone
HasZone(Base:base, ID:int)<decides><transacts>:void=
    {
        Currency := GetCurrencyConfig[Base, ID]
        Currency.MaybeCollectionZone?
        return
        
    }

Load(B:base, Purchaseable:PurchaseableType, I:int):void=
    if(Player := B.Players[0]):
        case(Purchaseable):
            PurchaseableType.Undefined =>{}

            PurchaseableType.BasicProp =>
            {if(X := B.BasicProps[I]){X.OnBought(Player)}}
            
            PurchaseableType.NPCBuyable =>
            {if(X := B.NPCSpawners[I]){X.OnBought(Player)}}

            PurchaseableType.Dropper =>
            {if(X := B.Droppers[I]){X.OnBought(Player)}}

            PurchaseableType.Conveyor =>
            {if(X := B.Conveyors[I]){X.OnBought(Player)}}

            PurchaseableType.Shootable =>
            {if(X := B.Shootables[I]){X.OnBought(Player)}}

            PurchaseableType.Hitable =>
            {if(X := B.Hitables[I]){X.OnBought(Player)}}

            PurchaseableType.DanceFloor =>
            {if(X := B.DanceFloors[I]){X.OnBought(Player)}}
    




#███████╗███╗░░██╗██╗░░░██╗███╗░░░███╗░██████╗
#██╔════╝████╗░██║██║░░░██║████╗░████║██╔════╝
#█████╗░░██╔██╗██║██║░░░██║██╔████╔██║╚█████╗░
#██╔══╝░░██║╚████║██║░░░██║██║╚██╔╝██║░╚═══██╗
#███████╗██║░╚███║╚██████╔╝██║░╚═╝░██║██████╔╝
#╚══════╝╚═╝░░╚══╝░╚═════╝░╚═╝░░░░░╚═╝╚═════╝░
AnimationStyle := enum:
    Grouped
    LegoLike
    LegoLike5x
    

LogicalStatus := enum:
    Enabled
    Disabled
PAnimation := enum:
    SlowFadeIn
    FadeIn
    FastFadeIn
Dependency := enum:
    Locked
    Unlocked
PurchaseableType := enum<persistable>:
    Undefined
    BasicProp
    Conveyor
    Dropper
    NPCBuyable
    Shootable
    Hitable
    DanceFloor

PurchasedStatus:= enum:
    Purchased
    NotPurchased
#░█████╗░██╗░░░░░░█████╗░░██████╗░██████╗███████╗░██████╗
#██╔══██╗██║░░░░░██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝
#██║░░╚═╝██║░░░░░███████║╚█████╗░╚█████╗░█████╗░░╚█████╗░
#██║░░██╗██║░░░░░██╔══██║░╚═══██╗░╚═══██╗██╔══╝░░░╚═══██╗
#╚█████╔╝███████╗██║░░██║██████╔╝██████╔╝███████╗██████╔╝
#░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═════╝░

log:=class<concrete>():
    @editable var EXPIRAMENTAL_RECEIVE_ALLLOGS:logic=false
    Superlog(I:string)<transacts>:void={if(EXPIRAMENTAL_RECEIVE_ALLLOGS?){Print("{I}")}}


money_league:=class<final>():
    #The amount per second being generated for each id
    var PerSecond:[int]int = map{}

    Update(B:base, ID:int, Amount:int, interval:float)<transacts><decides>:void=
        P:=B.Players[0]
        RebirthAmount := GetRebirthAmount[B, GetStats[P].Rebirths, Amount]
        AM :=Round[(RebirthAmount*1.0)/interval]
        set PerSecond[ID] = AM

UnlockFailure(Index:int, Name:string):void=
    Print("\n ==Failed to Unlock dependent== \n Failure Reason: \n {Name} with Index [{Index}] was already unlocked or it does not exist.")

currency_config := class<concrete><unique>(Inaugurable, Detailable):
    @editable var Name : string = ""
    @editable var Display : billboard_device = billboard_device{}
    @editable var MaybeCollectionZone : ?unique_buy_zone = option{unique_buy_zone{}}
    @editable var VFX : vfx_main = vfx_main{}
    var CollectionZone : unique_buy_zone = unique_buy_zone{}

   
    var AmountToClaim : int = 0
    var Owner:base=base{}
    
    Detail<override>(Type:string):void=
        Print("[== {Type} ==] \n Name: {Name}")

    Initialize<override>(Base:base):void=
        if(Zone := MaybeCollectionZone?){set CollectionZone = Zone}
        set Owner = Base
        CollectionZone.Initialize(Base)
        spawn{AwaitClaim()}
        spawn{Manager()}

        #Find the index where this currency is located in the base's currency list
        

        
            
        

    AddAwaitableCash(Amount:int)<transacts>:void=
        set AmountToClaim += Amount
    
    Manager()<suspends>:void=
        loop:
            race:
                AwaitClaim()
                UpdateText()
                

    UpdateText()<suspends>:void=
        Sleep(1.0)
        Display.SetText(S2M("{AmountToClaim}"))
        VFX.Initialize()
        return
        
    AwaitClaim()<suspends>:void=
            Agent := CollectionZone.PlayerEntersEvent.Await()
            if:
                Player := player[Agent]
                ID := GetCurrencyID[Owner, Self]
                PastCurrencyAmount:= GetStats[Player].AssociatedCurrencies[ID]
            then:
                UpdateAssociatedCurrencies(Player, ID, PastCurrencyAmount+AmountToClaim)
                set AmountToClaim = 0
                Display.SetText(S2M("{AmountToClaim}"))
                VFX.OnEvent()
                return
                
                
    


unique_buy_zone:=class<concrete>(Inaugurable, Toggleable):

    var Status : LogicalStatus = LogicalStatus.Disabled

    #Main buy zone
    @editable Zone : volume_device = volume_device{}

    #Transmits on these triggers when a player enters the buy zone
    @editable var TransmitToOnSuccess : []trigger_device = array{}

    var Initialized:logic=false
    Enable<override>():void={set Status = LogicalStatus.Enabled}
    Disable<override>()<transacts>:void={set Status = LogicalStatus.Disabled}
    PlayerEntersEvent: event(agent) = event(agent){}
    #Initializes the buy zone
    Initialize<override>(Base:base):void={
        #Re-enable the device if it was disabled
        set Status = LogicalStatus.Enabled

        #if the device is not initialized; then, spawn the await enterance function
        if(not Initialized?)
            {
            spawn{AwaitEnterance(Base)}
            }}

    #Waits for a player to enter the buy zone
    AwaitEnterance(Base:base)<suspends>:void=
        set Initialized = {true};
        loop:
            Sleep(0.0)
                #Wait for a player to enter the zone
                Agent := Zone.AgentEntersEvent.Await()

                if:
                    Player := player[Agent]
                    Base.Players.Find[Player]
                then:
                    #Check if the device is enabled
                    if(Status = LogicalStatus.Enabled):

                            #Signal a player entered
                            PlayerEntersEvent.Signal(Agent);

                            

                            
                                
                            
                    else{Print("The buy zone is disabled")}

purchase_set := class<concrete>:
    @editable Type: PurchaseableType = PurchaseableType.Undefined

    @editable Index: int = -1
base_setup := class<concrete>:
    #The description of the base.
    
    #The name of the base.
    @editable var Name: string = "My Base Name Here"
    @editable var TeamToAddTo : int = 0
    @editable var BaseClaimer : volume_device = volume_device{}
    @editable var PersistCurrencies: logic = true
    @editable var PersistUnlocks: logic = true
    @editable var RebirthButton : button_device = button_device{}
    @editable var RebirthCashMultiplier : float = 1.5
    @editable var VFX : vfx_main = vfx_main{}
    @editable var HudConfig : hud_main = hud_main{}


hud_main := class<concrete>():
    @editable var HudMessageDevice : hud_message_device = hud_message_device{}
    @editable var OnSuccessMessage : ?string = option{""}
    @editable var OnFailedMessage : ?string = option{""}

    OnSuccess(Base:base):void=
        if:
            Message := OnSuccessMessage?
        then:
            for:
                Player : Base.Players
            do:
                HudMessageDevice.StringShow(Message, Player)
        else:
            GlobalSuperlog("No on purchased message is set.")

    OnFail(Base:base):void=
        if:
            Message := OnFailedMessage?
        then:
            for:
                Player : Base.Players
            do:
                HudMessageDevice.StringShow(Message, Player)
        else:
            GlobalSuperlog("No on failed purchased message is set.")
        

    

vfx_main := class<concrete>():
    @editable var PreEventLoop : []vfx_spawner_device = array{}
    @editable var PostEvent : []vfx_spawner_device = array{}


    OnBegin():void=
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Disable()}

    OnEvent():void=
        for(VFX:PostEvent){VFX.Enable()}
        for(VFX:PreEventLoop){VFX.Disable()}
    
    Initialize():void=
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Enable()}

    
    
#██╗███╗░░██╗████████╗███████╗██████╗░███████╗░█████╗░░█████╗░███████╗░██████╗
#██║████╗░██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
#██║██╔██╗██║░░░██║░░░█████╗░░██████╔╝█████╗░░███████║██║░░╚═╝█████╗░░╚█████╗░
#██║██║╚████║░░░██║░░░██╔══╝░░██╔══██╗██╔══╝░░██╔══██║██║░░██╗██╔══╝░░░╚═══██╗
#██║██║░╚███║░░░██║░░░███████╗██║░░██║██║░░░░░██║░░██║╚█████╔╝███████╗██████╔╝
#╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚══════╝╚═════╝░
Detailable:=interface():

    Detail():void

Inaugurable:=interface():
    
    Initialize<public>(Base:base):void

SuperInaugurable:=interface():
    
    Initialize<public>(Base:base, I:int):void

Toggleable:=interface():
    Enable():void
    Disable():void

Hostable:=interface():
    Host()<suspends>:void

Rebirthable:=interface():
    OnRebirth():void
#███████╗███╗░░░███╗░█████╗░██████╗░███████╗
    

ConstructBase<constructor>(Src:base)<transacts>:=base:
    selfindex := Src.selfindex
    Status := Src.Status
    Players := Src.Players
    Owner := Src.Owner
    MoneyLeague := Src.MoneyLeague
    Base_Setup := Src.Base_Setup
    BasicProps := Src.BasicProps
    Collectables := Src.Collectables
    Conveyors := Src.Conveyors
    Currencies := Src.Currencies
    DanceFloors := Src.DanceFloors
    Droppers := Src.Droppers
    Gifts := Src.Gifts
    Hitables := Src.Hitables
    MoneyWheel := Src.MoneyWheel
    NPCSpawners := Src.NPCSpawners
    Shootables := Src.Shootables
    UIConfig := Src.UIConfig

    



