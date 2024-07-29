
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
using {cc}


#░█████╗░██╗░░░░░░█████╗░░██████╗░██████╗███████╗░██████╗
#██╔══██╗██║░░░░░██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝
#██║░░╚═╝██║░░░░░███████║╚█████╗░╚█████╗░█████╗░░╚█████╗░
#██║░░██╗██║░░░░░██╔══██║░╚═══██╗░╚═══██╗██╔══╝░░░╚═══██╗
#╚█████╔╝███████╗██║░░██║██████╔╝██████╔╝███████╗██████╔╝
#░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═════╝░

log<public>:=class<concrete>():
    @editable var EXPIRAMENTAL_DEBUG:logic=false
    Superlog<public>(I:string)<transacts>:void={if(EXPIRAMENTAL_DEBUG?){Print("{I}")}}


money_league<public>:=class<final>():
    #The amount per second being generated for each id
    var PerSecond<public>:[int]int = map{}

    Update<public>(B:base, ID:int, Amount:int, interval:float)<transacts><decides>:void=
        P:=B.Players[0]
        RebirthAmount := GetRebirthAmount[B, GetStats[P].Rebirths, Amount]
        AM :=Round[(RebirthAmount*1.0)/interval]
        set PerSecond[ID] = AM

UnlockFailure<public>(Index:int, Name:string):void=
    Print("\n ==Failed to Unlock dependent== \n Failure Reason: \n {Name} with Index [{Index}] was already unlocked or it does not exist.")

currency_config <public>:=class<concrete><unique>(Inaugurable, Detailable):
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
                CollectionZone.OnSuccess(Player)
                return
                
                
    


unique_buy_zone<public>:=class<concrete>(Inaugurable, Toggleable):

    var Status <public>: LogicalStatus = LogicalStatus.Disabled

    #Main buy zone
    @editable Zone <public>: volume_device = volume_device{}

    #Transmits on these triggers when a player enters the buy zone
    @editable var TransmitToOnSuccess  <public> : []trigger_device = array{}

    var Initialized:logic=false
    Enable<override>():void={set Status = LogicalStatus.Enabled}
    Disable<override>()<transacts>:void={set Status = LogicalStatus.Disabled}
    PlayerEntersEvent <public> : event(agent) = event(agent){}
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
    AwaitEnterance<public>(Base:base)<suspends>:void=
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
    OnSuccess<public>(Player:player):void=
        Print("On Success")
        for:
            Trigger : TransmitToOnSuccess
        do:
            Trigger.Trigger(Player)

purchase_set<public>:=class<concrete>:
    @editable Type <public> : PurchaseableType = PurchaseableType.Undefined

    @editable Index <public> : int = -1
base_setup<public>:=class<concrete>:
    #The description of the base.
    
    #The name of the base.
    @editable var Name <public> : string = "My Base Name Here"
    @editable var TeamToAddTo <public> : int = 0
    @editable var BaseClaimer <public> : volume_device = volume_device{}
    @editable var PersistCurrencies <public> : logic = true
    @editable var PersistUnlocks<public>: logic = true
    @editable var RebirthButton <public>: button_device = button_device{}
    @editable var RebirthCashMultiplier<public> : float = 1.5
    @editable var VFX <public>: vfx_main = vfx_main{}
    @editable var HudConfig <public> : hud_main = hud_main{}


hud_main<public>:=class<concrete>():
    @editable var HudMessageDevice : hud_message_device = hud_message_device{}
    @editable var OnSuccessMessage : ?string = option{""}
    @editable var OnFailedMessage : ?string = option{""}

    OnSuccess<public>(Base:base):void=
        if:
            Message := OnSuccessMessage?
        then:
            for:
                Player : Base.Players
            do:
                HudMessageDevice.StringShow(Message, Player)
        else:
            GlobalSuperlog("No on purchased message is set.")

    OnSuccessfullPlayer<public>(Player:player):void=
        if:
            Message := OnSuccessMessage?
        then:
            HudMessageDevice.StringShow(Message, Player)
        else:
            GlobalSuperlog("No on purchased message is set.")

    OnFail<public>(Base:base):void=
        if:
            Message := OnFailedMessage?
        then:
            for:
                Player : Base.Players
            do:
                HudMessageDevice.StringShow(Message, Player)
        else:
            GlobalSuperlog("No on failed purchased message is set.")
        

    

vfx_main<public>:=class<concrete>():
    @editable var PreEventLoop <public>: []vfx_spawner_device = array{}
    @editable var PostEvent <public> : []vfx_spawner_device = array{}


    OnBegin<public>():void=
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Disable()}

    OnEvent<public>():void=
        for(VFX:PostEvent){VFX.Enable()}
        for(VFX:PreEventLoop){VFX.Disable()}
    
    Initialize<public>():void=
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Enable()}

    




