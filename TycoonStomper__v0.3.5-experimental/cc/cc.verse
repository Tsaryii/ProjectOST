
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
        if:
            not PerSecond[ID]
        then:
            set PerSecond[ID] = AM
        else:
            set PerSecond[ID] += AM

UnlockFailure<public>(Index:int, Name:string):void=
    Print("\n ==Failed to Unlock dependent== \n Failure Reason: \n {Name} with Index [{Index}] was already unlocked or it does not exist.")

currency_config <public>:=class<concrete><unique>(Inaugurable, Detailable):
    @editable var Name : string = ""
    @editable var Display : billboard_device = billboard_device{}
    @editable var MaybeCollectionZone : ?unique_buy_zone = false
    @editable var VFX : vfx_main = vfx_main{}
    @editable var SFX : sfx_main = sfx_main{}
    var CollectionZone : unique_buy_zone = unique_buy_zone{}

   
    var AmountToClaim : int = 0
    var Owner:base=base{}
    
    Detail<override>(Type:string):void=
        Print("[== {Type} ==] \n Name: {Name}")

    Initialize<override>(Base:base):void=
        if(Zone := MaybeCollectionZone?){set CollectionZone = Zone}
        set Owner = Base
        CollectionZone.Initialize(Base, false)
        spawn{AwaitClaim()}
        spawn{Manager()}
        VFX.Initialize(Base)
        SFX.Initialize(Base)

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
                VFX.OnEvent(Player)
                SFX.OnEvent(Player)
                CollectionZone.OnSuccess(Player, false)
                return
                
                
    


unique_buy_zone<public>:=class<concrete>(LogicalInaugurable, Toggleable):

    var Status <public>: LogicalStatus = LogicalStatus.Disabled

    var Origin <public>: vector3 = vector3{}
    


    #Main buy zone
    @editable Zone <public>: volume_device = volume_device{}

    @editable HideOnSuccess <public> : logic = false

    @editable HideWhenParentIsLocked <public> : logic = false

    #Transmits on these triggers when a player enters the buy zone
    @editable var TransmitToOnSuccess  <public> : []trigger_device = array{}

    var Initialized:logic=false
    Enable<override>():void={set Status = LogicalStatus.Enabled, Show()}
    Disable<override>()<transacts>:void={set Status = LogicalStatus.Disabled; Hide(false); Print("Disabled");}
    PlayerEntersEvent <public> : event(agent) = event(agent){}
    #Initializes the buy zone
    Initialize<override>(Base:base, altvalue:logic):void={
        #Re-enable the device if it was disabled
        set Status = LogicalStatus.Enabled

        #if the device is not initialized; then, spawn the await enterance function
        if(not Initialized?)
            {
            spawn{AwaitEnterance(Base, altvalue)}
            }}

    


    #Waits for a player to enter the buy zone
    AwaitEnterance<public>(Base:base, altclaim:logic)<suspends>:void=
        set Initialized = {true};
        loop:
            PreventInf();
                #Wait for a player to enter the zone
                Agent := Zone.AgentEntersEvent.Await()
                if:
                    Player := player[Agent]
                    Base.Players.Find[Player] or altclaim? and Base.Players.Length < Base.SizeLimit
                then:
                    #Check if the device is enabled
                    if(Status = LogicalStatus.Enabled):
                        #Signal a player entered
                        PlayerEntersEvent.Signal(Agent);

    


                            

                            
                                
                            
                    else{Print("The buy zone is disabled")}

    AwaitUnlock<public>(P:purchaseable)<suspends>:void=
        if:
            HideWhenParentIsLocked?
        then:
            loop:
                if:
                    P.StartAs = Dependency.Locked
                then:
                    Disable()
                    block:
                        P.UnlockEvent.Await()
                        Enable()
                else:
                    P.StatusChange.Await()

                PreventInf();
                




    OnSuccess<public>(Player:player, DoHide:logic):void=
        for:
            Trigger : TransmitToOnSuccess
        do:
            Trigger.Trigger(Player)
        if:
            DoHide? and HideOnSuccess?
        then:
            spawn{HideOT(0.2)}
        

    
    HideOT<public>(Delay:float)<suspends>:void=
        zc := Zone.GetTransform().Translation; Sleep(Delay);
        if. Zone.TeleportTo[vector3{X:=zc.X, Y:=zc.Y, Z:=-10000.000}, rotation{}]

    Hide<public>(showlog:logic)<transacts>:void=
        zc := Zone.GetTransform().Translation
        if. Zone.TeleportTo[vector3{X:=zc.X, Y:=zc.Y, Z:=-10000.000}, rotation{}]
        else. if. showlog? then. GlobalSuperlog("Failed to hide on success")

    Show<public>()<transacts>:void=
        zc := Zone.GetTransform().Translation
        if. Zone.TeleportTo[Origin, rotation{}]


purchase_set<public>:=class<concrete>:
    @editable Type <public> : PurchaseableType = PurchaseableType.Undefined

    @editable Index <public> : int = -1
base_setup<public>:=class<concrete>(Inaugurable, RuntimeInaugurable):
    #The description of the base.
    
    #The name of the base.
    @editable var Name <public> : string = "My Base Name Here"
    @editable var TeamToAddTo <public> : int = 0
    @editable var BaseClaimer <public> : unique_buy_zone = unique_buy_zone{}
    @editable var PersistCurrencies <public> : logic = true
    @editable var PersistUnlocks<public>: logic = true
    @editable var RebirthButton <public>: button_device = button_device{}
    @editable var RebirthCashMultiplier<public> : float = 1.5
    @editable var DecimalTruncation <public> : ?int = option{1}
    @editable var VFX <public>: vfx_main = vfx_main{}
    @editable var SFX <public>: sfx_main = sfx_main{}
    @editable var HudConfig <public> : hud_main = hud_main{}
    @editable var BillBoardConfig <public> : billboard_main = billboard_main{}



    OnBegin<override>(Base:base, IX:int):void=
        Print("Base_Setup OnBegin")
        BaseClaimer.Initialize(Base, true)
        BillBoardConfig.OnBegin(-1)
        VFX.OnBegin(IX)
        SFX.OnBegin(IX)


    Initialize<override>(Base:base):void=
        BillBoardConfig.Initialize(Base)
        VFX.Initialize(Base)
        SFX.Initialize(Base)
        HudConfig.Initialize(Base)

#The base class that all purchaseables inherit from
hud_main<public>:=class<concrete>(StringInaugurable):
    @editable var HudMessageDevice : hud_message_device = hud_message_device{}
    @editable var OnSuccessMessage : ?string = option{""}
    @editable var OnFailedMessage : ?string = option{""}

    var MaybeOwner : ?StringReturnables = false

    #Disaplys a message to all players when X thing is successful
    OnSuccess<public>(Base:base):void=
        if:
            Message := OnSuccessMessage?
            Owner := MaybeOwner?
            StringedValue := GetStringParmaters[Message, Owner]
        then:
            for:
                Player : Base.Players
            do:
                HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on OnSuccess message is set. [Code:HUM-001]")
    
    #Displays a message to all players when X thing fails
    OnFail<public>(Base:base):void=
        if:
            Message := OnFailedMessage?
            Owner := MaybeOwner?
            StringedValue := GetStringParmaters[Message, Owner]
        then:
            for:
                Player : Base.Players
            do:
                HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on failed purchased message is set. [Code:HUM-002]")

    #Displays a message to a specific player when X thing is successful
    OnSuccessfullPlayer<public>(Player:player):void=
        if:
            Message := OnSuccessMessage?
            Owner := MaybeOwner?
            StringedValue := GetStringParmaters[Message, Owner]
        then:
            HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on OnSuccess message is set. [Code:HMP-001]")

    #Displays a message to a specific player when X thing fails
    OnFailurePlayer<public>(Player:player):void=
        if:
            Message := OnFailedMessage?
            Owner := MaybeOwner?
            StringedValue := GetStringParmaters[Message, Owner]
        then:
            HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on failed purchased message is set. [Code:HMP-002]")

    Initialize<override>(Owner:StringReturnables):void={set MaybeOwner = option{Owner}}

    

    

vfx_main<public>:=class<concrete>(Inaugurable, Runtime, FXSystem):
    @editable var PreEventLoop <public>: []vfx_spawner_device = array{}
    @editable var PostEvent <public> : []vfx_spawner_device = array{}


    OnBegin<override>(IX:int):void=
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Disable()}

    OnEvent<override>(P:player):void=
        for(VFX:PostEvent){VFX.Enable()}
        for(VFX:PreEventLoop){VFX.Disable()}

    EndEvent<override>():void=
        GlobalSuperlog("On VFX event")
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Enable()}
    
    Initialize<override>(Base:base):void=
        for(VFX:PostEvent){VFX.Disable()}
        for(VFX:PreEventLoop){VFX.Enable()}


sfx_main<public>:=class<concrete>(Inaugurable, Runtime, FXSystem):
    @editable var PreEventLoop <public>: []audio_player_device = array{}
    @editable var PostEvent <public> : []audio_player_device = array{}


    OnBegin<override>(IX:int):void=
        for(VFX:PostEvent){VFX.Stop()}
        for(VFX:PreEventLoop){VFX.Play()}

    OnEvent<override>(P:player):void=
        GlobalSuperlog("On SFX event")
        for(VFX:PostEvent){VFX.Play(P)}
        for(VFX:PreEventLoop){VFX.Stop(P)}

    EndEvent<override>():void=
        for(VFX:PostEvent){VFX.Stop()}
        for(VFX:PreEventLoop){VFX.Play()}
    
    Initialize<override>(Base:base):void=
        for(VFX:PostEvent){VFX.Stop()}
        for(VFX:PreEventLoop){VFX.Play()}

fx_main<public>:=class<concrete>():
    @editable EventBasedVFX <public> : vfx_main = vfx_main{}
    @editable EventBasedSFX <public> : sfx_main = sfx_main{}
    @editable var RestartWhenActivated <public> : logic = false
    @editable var FXLength <public> : float = 0.1


billboard_main<public>:=class<concrete>(LogicalVisibility, Runtime, StringInaugurable):

    var MaybeOwner : ?StringReturnables = false

    @editable var BillboardDevice <public> : billboard_device = billboard_device{}

    @editable var BillboardText <public> : string = {
    "[Name] \n [Price]"}

    # @editable var OffsetAmount <public> : ?transform = option{transform{Translation := vector3{X:=0.0, Y:=0.0, Z:=0.0}, Scale := vector3{X:=1.0, Y:=1.0, Z:=1.0}}}





    Show<override>():void={BillboardDevice.ShowText()}

    Hide<override>():void={BillboardDevice.HideText()}

    OnBegin<override>(IX:int):void={Hide()}

    Initialize<override>(Owner:StringReturnables):void={set MaybeOwner = option{Owner}}


    #Updates and Shows the billboard text
    Instantiate<public>():void=
        if:
            Owner := MaybeOwner?
            BillboardStringedValue := GetStringParmaters[BillboardText, Owner]
        then:
            BillboardDevice.SetText(S2M(BillboardStringedValue)); Show()
        else:
            GlobalSuperlog("`Unknown` Owner | Failed to instantiate text as StringParameters could not be found in `Unknown` Owner")
    
    

