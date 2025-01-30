
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using {Materials}
using {Purchaseables}
using {Runtimeinstantiables}
using {cc}

<#

░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗
██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║
██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║
██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║
╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║
░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝

░█████╗░██╗░░░░░░█████╗░░██████╗░██████╗███████╗░██████╗░░░██╗░░░██╗███████╗██████╗░░██████╗███████╗
██╔══██╗██║░░░░░██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝░░░██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝
██║░░╚═╝██║░░░░░███████║╚█████╗░╚█████╗░█████╗░░╚█████╗░░░░╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░
██║░░██╗██║░░░░░██╔══██║░╚═══██╗░╚═══██╗██╔══╝░░░╚═══██╗░░░░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░
╚█████╔╝███████╗██║░░██║██████╔╝██████╔╝███████╗██████╔╝██╗░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗
░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═════╝░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝

█▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▀ █▀▄   █▄▄ █▄█   ▀█▀ █▀ ▄▀█ █▀█
█▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ ██▄ █▄▀   █▄█ ░█░   ░█░ ▄█ █▀█ █▀▄

▄▀█ █░░ █░░   █▀█ █ █▀▀ █░█ ▀█▀ █▀   █▀█ █▀▀ █▀ █▀▀ █▀█ █░█ █▀▀ █▀▄
█▀█ █▄▄ █▄▄   █▀▄ █ █▄█ █▀█ ░█░ ▄█   █▀▄ ██▄ ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▄▀

█▀▄ █▀█   █▄░█ █▀█ ▀█▀   █▀ █▀▀ █░░ █░░
█▄▀ █▄█   █░▀█ █▄█ ░█░   ▄█ ██▄ █▄▄ █▄▄
#>

var UsingDebug<public>:weak_map(session, logic) = map{}
var UsingTimeout<public>:weak_map(session, float) = map{}


log<public>:=class<concrete>():
    @editable{ToolTip:=DevVersionTT} var DevVersion : ActiveVersion = ActiveVersion.Beta_0_3_6_0
    @editable{ToolTip:=BackwardsCompatibilityTT} var BackwardsCompatibility: BackwardsCompatible = BackwardsCompatible.None
    @editable{ToolTip:=GlobalDebugToolsTT} var GlobalDebugTools:logic=false
    @editable{ToolTip:=GlobalTimeoutTT} var GlobalTimeout:float=1.0
    Superlog<public>(I:string)<transacts>:void=
        if:
            GlobalDebugTools?
        then:
            Print("{I}")
            if. set UsingDebug[GetSession()] = true
            if. set UsingTimeout[GetSession()] = GlobalTimeout



#abc
money_league<public>:=class<final>():
    #The amount per second being generated for each id
    var PerSecond<public>:[int]int = map{}

    Update<public>(B:base, ID:int, Amount:int, interval:float)<transacts><decides>:void=
        P:=B.Players[0]
        RebirthAmount := GetRebirthAmount[B, GetCoreStats[P, B.Base_Setup.PersistenceCore].Rebirths, Amount]
        AM :=Round[(RebirthAmount*1.0)/interval]
        if:
            not PerSecond[ID]
        then:
            set PerSecond[ID] = AM
        else:
            set PerSecond[ID] += AM

UnlockFailure<public>(Index:int, Name:string):void=
    GlobalSuperlog("\n ==Failed to Unlock dependent== \n Failure Reason: \n {Name} with Index [{Index}] was already unlocked or it does not exist.")
    
Super<public>:=module{
    TestSuper<public>():logic=true
    CurencyValue():void=Print("[CurrencyValue]")
                                                                                                                                                        CurrencyValue<public>():void={Print("𝒀𝒐𝒖 𝒂𝒓𝒆 𝒖𝒔𝒊𝒏𝒈 𝑷𝒓𝒐𝒋𝒆𝒄𝒕 𝑶𝑺𝑻, 𝑫𝒆𝒗𝒆𝒍𝒐𝒑𝒆𝒅 𝑩𝒚 𝑻𝒔𝒂𝒓, 𝒅𝒐 𝒏𝒐𝒕 𝒔𝒆𝒍𝒍 𝒕𝒉𝒊𝒔 𝒌𝒊𝒕 𝒊𝒕❜𝒔 𝒄𝒐𝒑𝒚𝒍𝒆𝒇𝒕.")}
}

currency_config <public>:=class<concrete><unique>(Inaugurable, Detailable):
    @editable var Name : string = ""
    @editable var Display : billboard_device = billboard_device{}
    @editable var MaybeCollectionZone : ?anyzone_or_atm = false
    @editable var VFX : vfx_main = vfx_main{}
    @editable var SFX : sfx_main = sfx_main{}
    var CollectionZone : anyzone_or_atm = anyzone_or_atm{}

   
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
        Display.SetText(S2M("{AmountToClaim.GetTrunc(Owner)}"))
        return
        
    AwaitClaim()<suspends>:void=
            Agent := CollectionZone.PlayerEntersEvent.Await()
            if:
                Player := player[Agent]
                ID := GetCurrencyID[Owner, Self]
                PastCurrencyAmount:= GetCoreStats[Player, Owner.Base_Setup.PersistenceCore].AssociatedCurrencies[ID]
            then:
                UpdateAssociatedCurrencies(Player, ID, PastCurrencyAmount+AmountToClaim, Owner.Base_Setup.PersistenceCore)
                set AmountToClaim = 0
                Display.SetText(S2M("{AmountToClaim.GetTrunc(Owner)}"))
                VFX.OnEvent(Player)
                SFX.OnEvent(Player)
                CollectionZone.OnSuccess(Player, false)
                return
                
                
    


anyzone_or_atm<public>:=class<concrete>(LogicalInaugurable, Toggleable):

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
    DelayedPlayerEntersEvent <public> : event(agent) = event(agent){}

    
    #Initializes the buy zone
    Initialize<override>(Base:base, altvalue:logic):void={
        #Re-enable the device if it was disabled
        set Status = LogicalStatus.Enabled
        set Origin = Zone.GetTransform().Translation

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
                Agent := Zone.AgentEntersEvent.Await(); GlobalSuperlog("Player Entered")
                if:
                    Player := player[Agent]
                    Base.Players.Find[Player] or altclaim? and Base.Players.Length < Base.SizeLimit
                then:
                    #Check if the device is enabled
                    if(Status = LogicalStatus.Enabled):
                        #Signal a player entered
                        PlayerEntersEvent.Signal(Agent);
                        spawn{RetryPlayerEntersEvent(Agent)}

                    else{Print("The buy zone is disabled")}
                else:
                    Print("Failed to enter the buy zone")
                        

    


                            

                            
                                
                            
                   
    RetryPlayerEntersEvent<public>(Agent:agent)<suspends>:void={Sleep(0.1); DelayedPlayerEntersEvent.Signal(Agent); Print("Delayed Player Enters Event")}

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
    @editable {ToolTip:=PersistenceCoreTT} var PersistenceCore <public> : int = 0
    @editable {ToolTip:=TeamToAddToTT} var TeamToAddTo <public> : int = 0
    @editable {ToolTip:=PersistCurrenciesTT}var PersistCurrencies <public> : logic = true
    @editable {ToolTip:=PersistUnlocksTT}var PersistUnlocks<public>: logic = true
    @editable {ToolTip:=DecimalTruncationTT}var DecimalTruncation <public> : ?int = option{1}
    @editable var VFX <public>: vfx_main = vfx_main{}
    @editable var SFX <public>: sfx_main = sfx_main{}
    @editable var HudConfig <public> : hud_main = hud_main{OnFailedMessage := option{"Failed to claim base [FailureReason]"}; OnSuccessMessage := option{"Successfully claimed base [Name]"}}
    @editable var BillBoardConfig <public> : billboard_main = billboard_main{}
    @editable var RebirthConfig <public> : rebirth_main = rebirth_main{}
    @editable {ToolTip:=PurchaseableConfigTT}var PurchaseableConfigs <public> : basic_prop_buyable = basic_prop_buyable{
        Name := "Base Setup"
        Description := "Most Settings here: \ndo not apply \nor they do nothing"
        DefaultAltClaim := true
    }



    OnBegin<override>(Base:base, IX:int):void=
        GlobalSuperlog("Base_Setup OnBegin")
        PurchaseableConfigs.Initialize(Base, 0)
        BillBoardConfig.OnBegin(-1)
        RebirthConfig.RebirthButton.Disable()
        HudConfig.Initialize(Base)
        VFX.OnBegin(IX)
        SFX.OnBegin(IX)

    Initialize<override>(Base:base):void=
        BillBoardConfig.Initialize(Base)
        VFX.Initialize(Base)
        SFX.Initialize(Base)
        HudConfig.Initialize(Base)
        GlobalSuperlog("INITIED BASE SETUP")
        RebirthConfig.Initialize(Base)

TWC_unique_prop<public>:=class<unique><concrete>(SuperClassInaugurable):

    @editable var SetName <public> : string = "My Set Name Here"

    @editable var PrePurchaseFunction <public> : PropMovementType = PropMovementType.Nothing

    @editable var OnPurchaseFunction <public> : PurchaseMovementType = PurchaseMovementType.Show

    @editable var Color_Change_Index : int = 0

    @editable var Material_Change_Index : int = 0

    @editable var Animates <public> : logic = true

    @editable var HideOnGameStart <public> : logic = true

    @editable var props <public>: []creative_prop = array{}



    var OriginProps <public>: []origin_prop = array{}


    var Status: LogicalVisibilityStatus = LogicalVisibilityStatus.Shown

    Initialize<override>(Owner:purchaseable):void=
        GlobalSuperlog("Initialized")
        if:
            HideOnGameStart?
        then:
            GlobalSuperlog("Hiding on game start")
            Hide(Owner.AnimationConfig)
            set Status = LogicalVisibilityStatus.Hidden
            for. PropIn:OriginProps
            do. set PropIn.Visibility = LogicalVisibilityStatus.Hidden
        else:
            set Status = LogicalVisibilityStatus.Shown
            for. PropIn:OriginProps
            do. set PropIn.Visibility = LogicalVisibilityStatus.Shown

    SwitchToRed<public>()<transacts><decides>:void=
        PropToChange := props[Color_Change_Index]
        PropToChange.SetMaterial(MI_Simple_PureRed_Flat_Inst, ?Index:=Material_Change_Index)

    SwitchToGreen<public>()<transacts><decides>:void=
        PropToChange := props[Color_Change_Index]
        PropToChange.SetMaterial(MI_Simple_PureGreen_Flat_Inst, ?Index:=Material_Change_Index)
    
    Hide<public>(Anim:animation_main):void=
        for:
            Prop:props
        do:
            Prop.Hide()
        if:
            Animates?
            Status = LogicalVisibilityStatus.Shown
        then:
            Anim.HideProps(props)
        else if:
            Status = LogicalVisibilityStatus.Shown
        then:
            Anim.HideProps(props)

        set Status = LogicalVisibilityStatus.Hidden

    Show<public>(Anim:animation_main)<suspends>:void=
        for:
            Prop:props
        do:
            Prop.Show()
        if:
            Animates? and Status = LogicalVisibilityStatus.Hidden
        then:
            Anim.ShowProps(OriginProps)
        else if:
            Status = LogicalVisibilityStatus.Hidden
        then:
            var AnimLess : animation_main = Anim
            set AnimLess.PurchaseAnimationStyle = AnimationStyle.none
            Anim.ShowProps(OriginProps)

        set Status = LogicalVisibilityStatus.Shown


    

    

origin_prop<public>:=class<unique>(Inaugurable):
    prop <public> : creative_prop
    var origin <public>: transform
    var owner <public> : ?base = false
    var Visibility<public>: LogicalVisibilityStatus = LogicalVisibilityStatus.Undefined

    Initialize<override>(Owner:base):void=
        set owner = option{Owner}
        set origin = prop.GetTransform()

    SetToOrigin<public>(ManageVisibility:logic)<transacts>:void=
        if:
            owner?
            prop.TeleportTo[origin.Translation, origin.Rotation]
        then:
            if:
                ManageVisibility?
            then:
                if:
                    Visibility = LogicalVisibilityStatus.Shown
                then:
                    prop.Show()
                else if:
                    Visibility = LogicalVisibilityStatus.Hidden
                then:
                    prop.Hide()
custom_waypointable_config<public>:=class<concrete>():

    @editable var ConveyorID        <public> : int = 0
    @editable var WaypointID        <public> : int = 0




