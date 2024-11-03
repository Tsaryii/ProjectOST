
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
using {cc}

<#

░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗  ░█████╗░██╗░░░░░░█████╗░░██████╗░██████╗███████╗░██████╗
██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║  ██╔══██╗██║░░░░░██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝
██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║  ██║░░╚═╝██║░░░░░███████║╚█████╗░╚█████╗░█████╗░░╚█████╗░
██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║  ██║░░██╗██║░░░░░██╔══██║░╚═══██╗░╚═══██╗██╔══╝░░░╚═══██╗
╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║  ╚█████╔╝███████╗██║░░██║██████╔╝██████╔╝███████╗██████╔╝
░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝  ░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═════╝░

███╗░░░███╗░█████╗░██╗███╗░░██╗░░░██╗░░░██╗███████╗██████╗░░██████╗███████╗
████╗░████║██╔══██╗██║████╗░██║░░░██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝
██╔████╔██║███████║██║██╔██╗██║░░░╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░
██║╚██╔╝██║██╔══██║██║██║╚████║░░░░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░
██║░╚═╝░██║██║░░██║██║██║░╚███║██╗░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝
@tsarry
#>


rebirth_main<public>:=class<concrete>(Inaugurable, PlayerSpecificStringReturnables):
    @editable var RebirthButton <public>: button_device = button_device{}
    @editable var RebirthCashMultiplier<public> : float = 1.5
    @editable var RebirthCost <public> : float = 1000.0
    @editable var RebirthCostCurrencyID <public> : int = 0
    @editable var RebirthCostMultiplier <public> : float = 1.5
    @editable var HudConfig <public> : hud_main = hud_main{OnFailedMessage := option{"Failed to rebirth you need [RebirthAmountNeeded]"}; OnSuccessMessage := option{"You have rebirthed! Every 100 now = [RebirthCashMultiplier]"}}
    @editable var RebirthAccolade <public> : accolades_device = accolades_device{}


    var MaybeOwner : ?base = false

    Initialize<override>(Base:base):void=
        set MaybeOwner = option{Base}
        HudConfig.Initialize(Self)
        RebirthButton.Enable()

    GetStringParams<override>(P:?player)<transacts>:[string]string=
        var default : [string]string =  map
        {
            "[RebirthCashMultiplier]"=>"{RebirthCashMultiplier}", 
            "[RebirthCost]"=>"{RebirthCost}",
            "[RebirthCostCurrencyID]"=>"{RebirthCostCurrencyID}",
            "[RebirthCostMultiplier]"=>"{RebirthCostMultiplier}"
        }
        if:
            Player := P?
            Owner := MaybeOwner?
            PlayerStats := GetStats[Player]
            Rebirths := PlayerStats.Rebirths
            RebirthCurrencyValue := PlayerStats.AssociatedCurrencies[Owner.Base_Setup.RebirthConfig.RebirthCostCurrencyID]
            RebirthCostAmount := GetRebirthCostAmount[Owner, Rebirths]
            RebirthMultiple := GetRebirthAmount[Owner, Rebirths, 100]
        then:
            if:
                set default["[RebirthAmountNeeded]"] = "{RebirthCostAmount-RebirthCurrencyValue}"
                set default["[RebirthCashMultiplier]"] = "{RebirthMultiple}"
            then:
                GlobalSuperlog("Multiple is {RebirthMultiple}")

        return default

    
#The base class that all purchaseables inherit from
hud_main<public>:=class<concrete>(StringInaugurable):
    @editable var HudMessageDevice : hud_message_device = hud_message_device{}
    @editable var OnSuccessMessage <public>: ?string = option{""}
    @editable var OnFailedMessage <public> : ?string = option{""}

    var MaybeOwner : ?StringReturnables = false

    #Disaplys a message to all players when X thing is successful
    OnSuccess<public>(Base:base):void=
        if:
            Message := OnSuccessMessage?
            Owner := MaybeOwner?
            
        then:
            for:
                Player : Base.Players
                StringedValue := GetStringParmaters[option{Player}, Message, Owner]
            do:
                HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on OnSuccess message is set. [Code:HUM-001]")
    
    #Displays a message to all players when X thing fails
    OnFail<public>(Base:base):void=
        if:
            Message := OnFailedMessage?
            Owner := MaybeOwner?
        then:
            for:
                Player : Base.Players
                StringedValue := GetStringParmaters[option{Player}, Message, Owner]
            do:
                HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on failed purchased message is set. [Code:HUM-002]")

    #Displays a message to a specific player when X thing is successful
    OnSuccessfullPlayer<public>(Player:player):void=
        if:
            Message := OnSuccessMessage?
            Owner := MaybeOwner?
            StringedValue := GetStringParmaters[option{Player}, Message, Owner]
        then:
            GlobalSuperlog("Stringed Value is {StringedValue} |")
            HudMessageDevice.StringShow(StringedValue, Player)
        else:
            GlobalSuperlog("No on OnSuccess message is set. [Code:HMP-001]")

    #Displays a message to a specific player when X thing fails
    OnFailurePlayer<public>(Player:player):void=
        if:
            Message := OnFailedMessage?
            Owner := MaybeOwner?
            StringedValue := GetStringParmaters[option{Player}, Message, Owner]
            GlobalSuperlog("Stringed Value is {StringedValue}")
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
    "[Name] \n[Description] \nRebirthsNeeded: [RebirthsNeeded] \n$[Price]"}

    # @editable var OffsetAmount <public> : ?transform = option{transform{Translation := vector3{X:=0.0, Y:=0.0, Z:=0.0}, Scale := vector3{X:=1.0, Y:=1.0, Z:=1.0}}}





    Show<override>():void={BillboardDevice.ShowText()}

    Hide<override>():void={BillboardDevice.HideText()}

    OnBegin<override>(IX:int):void={Hide()}

    Initialize<override>(Owner:StringReturnables):void={set MaybeOwner = option{Owner}}


    #Updates and Shows the billboard text
    Instantiate<public>():void=
        if:
            Owner := MaybeOwner?
            BillboardStringedValue := GetStringParmaters[false, BillboardText, Owner]
        then:
            BillboardDevice.SetText(S2M(BillboardStringedValue)); Show()
        else:
            GlobalSuperlog("`Unknown` Owner | Failed to instantiate text as StringParameters could not be found in `Unknown` Owner")
    
animation_main<public>:=class<final><concrete>():

    #Defines the prop's Z coord for every PAnimation type: which is where it will be held stationary.
    # A negative value means the prop will start at -GranualarDist and move to +GranualarDist
    # A positive value means the prop will start at +GranualarDist and move to -GranualarDist
    # Using groupedReverse flips these values
    @editable var GranualarDist <public>: float = + 1500.0
    
    @editable var  PurchaseAnimationStyle <public> : AnimationStyle = AnimationStyle.Grouped
    # The animation style for the purchase animation
    
    @editable var  PurchaseAnimationSpeed <public> : float = 10.0
    # The specific purchase animation to use


        #Defines the arguements for every PAnimation type
        var PropAlterations:int=0

        #Hides the props associated with the item
        #The props are then moved to a location below the player with a specified animation speed
    HideProps<public>(PropsToAlter:[]creative_prop)<transacts>:void=
            set PropAlterations -= 1
            for(I -> Prop:PropsToAlter){
            if:
                Prop.IsValid[]
            then:
                Prop.Hide()
                PT := Prop.GetTransform().Translation
                PR := Prop.GetTransform().Rotation
                PL := vector3{X:=PT.X, Y:=PT.Y, Z:=PT.Z+GranualarDist}
                if(Prop.TeleportTo[PL, PR]){}
    
            }
            return
        #Shows the props associated with the item
    ShowProps<public>(PropsToAlter:[]origin_prop)<suspends>:void=
            set PropAlterations += 1
            for(I -> Prop:PropsToAlter)
            {
                if:
                    Prop.prop.IsValid[]
                then:
                    PR := Prop.prop.GetTransform().Rotation
    
    
                    case(PurchaseAnimationStyle):
                        AnimationStyle.Grouped =>
                            Prop.prop.Show()
                            spawn{Prop.prop.MoveTo(Prop.origin, 10.0/PurchaseAnimationSpeed)}

    
                        AnimationStyle.LegoLike =>
                            Prop.prop.Show()
                            Prop.prop.MoveTo(Prop.origin, 10.0/PurchaseAnimationSpeed)
    
    
                        AnimationStyle.none =>
                            if. Prop.prop.TeleportTo[Prop.origin]
                            Prop.prop.Show()
                            
            }
            return

    MoveToOrigin<public>(PropsToAlter:[]creative_prop)<transacts>:void=
        set PropAlterations -= 1
        for(I -> Prop:PropsToAlter){
        if:
            Prop.IsValid[]
        then:
            PT := Prop.GetTransform().Translation
            PR := Prop.GetTransform().Rotation
            PL := vector3{X:=PT.X, Y:=PT.Y, Z:=PT.Z-GranualarDist}
            if(Prop.TeleportTo[PL, PR]){}

        }
        return