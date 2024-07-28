
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }


<#

THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE

-If you are using this code in your own project you do not have permission to publish it.
-You must attain a license from the author of this giftbox to publish a map whilst using this code.

This code is only for educational purposes 
it should not be used in a commercial project without permission from the original author.

Although I've modified this code, 
it wasn't written by me: I purchased it on the internet and I'm sharing it with you.


THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE
THIS CODE IS NOT FOR COMMERCIAL USE


#>
giftbox_device := class<concrete>(Inaugurable):


    var owner:base = base{}

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    GiftBoxProp<public> : creative_prop = creative_prop{}

    @editable
    GiftBoxButton<public> : button_device = button_device{}

    @editable
    GiftGranter<public> : item_granter_device = item_granter_device{}

    @editable
    GiftBoxDurations<public> : []int = array{}

    TextForUI<localizes>(InText : string) : message = "{InText}"

    OnDurationBought : event(int) = event(int){}

    var GiftTextStartIndex : int = -1
    var GiftTextEndIndex : int = -1
    var GiftImageStartIndex : int = -1
    var GiftImageEndIndex : int = -1

    var GiftBoxCanvasPerAgent : [agent]canvas = map{}
    var GiftBoxDurationsPerAgent : [agent][]int = map{}

    var GiftBoxAnimationKeyFrames : []keyframe_delta = array{}

    Initialize<override>(Base:base):void=
        GiftBoxButton.InteractedWithEvent.Subscribe(OnGiftBoxButtonInteracted)
        WaitKeyFrame: keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{X:=0.0,Y:=0.0,Z:=0.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0 }
            Time := 0.6
            Interpolation := EaseInOut
        }

        UpMovementKeyFrame: keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{X:=0.0,Y:=0.0,Z:=100.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3 { X:=1.0, Y:=0.6, Z:=1.3 }
            Time := 0.2
            Interpolation := EaseOut
        }

        DownMovementKeyFrame: keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{X:=0.0,Y:=0.0,Z:=-120.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3 { X:=1.0, Y:=1.0/0.6, Z:=0.6/1.3 }
            Time := 0.2
            Interpolation := EaseIn
        }

        DownMovementCompleteKeyFrame: keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{X:=0.0,Y:=0.0,Z:=20.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0/0.6 }
            Time := 0.12
            Interpolation := EaseIn
        }

        set GiftBoxAnimationKeyFrames = array{ WaitKeyFrame, UpMovementKeyFrame, DownMovementKeyFrame, DownMovementCompleteKeyFrame }
        if (PropAnimController := GiftBoxProp.GetAnimationController[]):
            PropAnimController.SetAnimation(GiftBoxAnimationKeyFrames, ?Mode := animation_mode.Loop)
            PropAnimController.Play()

        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        spawn{AsyncTickPerSecond()}

    AsyncTickPerSecond()<suspends>:void=
        loop:
            Sleep(1.0)

            Players := owner.Players
            for (Player : Players, GiftBoxCanvas : canvas = GiftBoxCanvasPerAgent[Player]):
                for (I := 0 .. GiftBoxDurations.Length-1, Duration : int = GiftBoxDurationsPerAgent[Player][I]):
                    TextIndex := GiftTextStartIndex + I
                    ImageIndex := GiftImageStartIndex + I

                    if (Duration > -1,
                    TextWidget : text_block = text_block[GiftBoxCanvas.Slots[TextIndex].Widget],
                    ImageWidget : texture_block = texture_block[GiftBoxCanvas.Slots[ImageIndex].Widget]):
                        if (set GiftBoxDurationsPerAgent[Player][I] = Duration-1){}

                        if ((Duration-1) = -1):
                            TextWidget.SetText(TextForUI("✔️"))
                            ImageWidget.SetImage(Textures.T_TreasureClaimed)
                            OnDurationBought.Signal(I)
                            GlobalSuperlog("Showing as claimed")

                            CanvasVisibility := GiftBoxCanvas.GetVisibility()
                            if (CanvasVisibility = widget_visibility.Visible):
                                if (set GiftBoxDurationsPerAgent[Player][I] = -2){}
                                GiftGranter.SetNextItem(I)
                                GiftGranter.GrantItem(Player)
                                
                        else:
                            TextWidget.SetText(TextForUI(GetFormattedTimeString(Duration-1)))
                    else:
                        GlobalSuperlog("Failed smth")

    GetFormattedTimeString(TimeInSecs : int)<transacts>:string=
        var FormattedTimeString : string = ""
        HourTime : float = (TimeInSecs * 1.0) / 3599.9
        if(FlooredHourTime := Floor[HourTime]):
            if(FlooredHourTime > 0):
                if(FlooredHourTime < 10):
                    set FormattedTimeString += "0"
                set FormattedTimeString += ToString(FlooredHourTime) + ":"
            RemainedMinutesTime : float = HourTime - (FlooredHourTime * 1.0)

            MinuteTime : float = RemainedMinutesTime * 59.9
            if(FlooredMinuteTime := Floor[MinuteTime]):
                if(FlooredMinuteTime < 10):
                    set FormattedTimeString += "0" + ToString(FlooredMinuteTime) + ":"
                else:
                    set FormattedTimeString += ToString(FlooredMinuteTime) + ":"
                RemainedSecondsTime : float = MinuteTime - (FlooredMinuteTime * 1.0)

                SecondsTime : float = RemainedSecondsTime * 59.9
                if(FlooredSecondsTime := Floor[SecondsTime]):
                    if(FlooredSecondsTime < 10):
                        set FormattedTimeString += "0" + ToString(FlooredSecondsTime)
                    else:
                        set FormattedTimeString += ToString(FlooredSecondsTime)

        return FormattedTimeString

    OnPlayerSpawned(Agent : agent):void=
        if (GiftBoxCanvas := GiftBoxCanvasPerAgent[Agent]):
            return

        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            GiftBoxCanvas : canvas = CreateGiftBoxCanvas()

            var AgentGiftBoxDurations : []int = array{}

            for (GiftBoxDuration : GiftBoxDurations):
                set AgentGiftBoxDurations += array{ GiftBoxDuration }

            if (set GiftBoxCanvasPerAgent[Agent] = GiftBoxCanvas){}
            if (set GiftBoxDurationsPerAgent[Agent] = AgentGiftBoxDurations){}

            GiftBoxCanvas.SetVisibility(widget_visibility.Collapsed)

    OnGiftBoxButtonInteracted(Agent : agent):void=
        GlobalSuperlog("OnGiftBoxButtonInteracted")

        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player], GiftBoxCanvas := GiftBoxCanvasPerAgent[Agent],
        AgentGiftBoxDurations : []int = GiftBoxDurationsPerAgent[Agent]):
            GiftBoxCanvas.SetVisibility(widget_visibility.Visible)
            PlayerUI.AddWidget(GiftBoxCanvas, player_ui_slot{InputMode := ui_input_mode.All})

            for (I := 0..GiftBoxDurations.Length-1, GiftBoxDuration := AgentGiftBoxDurations[I]):
                if (GiftBoxDuration = -1):
                    if (set GiftBoxDurationsPerAgent[Agent][I] = -2){}
                    GiftGranter.SetNextItem(I)
                    GiftGranter.GrantItem(Agent)
                    GlobalSuperlog("Gift {I} Granted to a Player")

    OnQuitButtonClicked(WidgetMessage : widget_message):void=
        if (PlayerUI := GetPlayerUI[WidgetMessage.Player], GiftBoxCanvas := GiftBoxCanvasPerAgent[WidgetMessage.Player]):
            PlayerUI.RemoveWidget(GiftBoxCanvas)
            GiftBoxCanvas.SetVisibility(widget_visibility.Collapsed)

    CreateGiftBoxCanvas():canvas=
        var CanvasSlots : []canvas_slot = array{}

        var RewardTextureBlocks : []texture_block = array{}
        for (I := 1 .. 4):
            set RewardTextureBlocks += array
            {
                texture_block{DefaultImage := Textures.T_TreasureChest1, DefaultDesiredSize := vector2{ X := 107.2, Y := 115.2 }}
            }

        for (I := 1 .. 4):
            set RewardTextureBlocks += array
            {
                texture_block{DefaultImage := Textures.T_TreasureChest2, DefaultDesiredSize := vector2{ X := 105.6, Y := 122.4 }}
            }

        for (I := 1 .. 2):
            set RewardTextureBlocks += array
            {
                texture_block{DefaultImage := Textures.T_TreasureChest3, DefaultDesiredSize := vector2{ X := 140.8,Y := 124.0 }}
            }

        set RewardTextureBlocks += array
        {
            texture_block{DefaultImage := Textures.T_TreasureChest4, DefaultDesiredSize := vector2{ X:= 140.0, Y:=133.6 }}
        }

        set RewardTextureBlocks += array
        {
            texture_block{DefaultImage := Textures.T_TreasureChest5, DefaultDesiredSize := vector2{ X := 120.8, Y := 136.8 }}
        }

        var RewardButtonTextureBlocks : []texture_block = array{}
        for (I := 1 .. 12):
            set RewardButtonTextureBlocks += array
            {
                texture_block{DefaultImage := Textures.T_TreasureWait, DefaultDesiredSize := vector2{ X := 135.0, Y := 47.0 }}
            }
        
        var TimeTexts : []string = array{}
        for (GiftBoxDuration : GiftBoxDurations):
            set TimeTexts += array{ GetFormattedTimeString(GiftBoxDuration) }

        var RewardTimeTextBlocks : []text_block = array{}
        for (I := 1 .. 12, TimeText := TimeTexts[I-1]):
            RewardTimeTextBlock : text_block = text_block{DefaultText := TextForUI(TimeText), DefaultTextColor := NamedColors.White, DefaultJustification := text_justification.Center}
            RewardTimeTextBlock.SetShadowColor(NamedColors.Black)
            RewardTimeTextBlock.SetShadowOffset(option{vector2{ X := 3.0, Y := 3.0 }})
            RewardTimeTextBlock.SetShadowOpacity(1.0)

            set RewardTimeTextBlocks += array
            {
                RewardTimeTextBlock
            }

        CenterVector : vector2 = vector2{X:=0.5, Y:=0.5}
        CenterAnchors : anchors = anchors{Minimum := CenterVector, Maximum := CenterVector}
        set CanvasSlots += array
        {
            canvas_slot:
                Anchors := CenterAnchors
                Offsets := margin{Top:= 0.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := CenterVector
                SizeToContent := true
                Widget := texture_block{DefaultImage := Textures.T_TreasureBG, DefaultDesiredSize := vector2{ X:= 800.0,Y := 800.0}}
        }

        RewardTextureBlockYOffsets : []float = array{ -195.0, -10.0, 180.0 }
        RewardTextureBlockXOffsets : []float = array{ -195.0, -45.0, 105.0, 255.0 }
        var Index : int = 0        
        for (YOffset : RewardTextureBlockYOffsets):
            for (XOffset : RewardTextureBlockXOffsets, RewardTextureBlock := RewardTextureBlocks[Index]):
                set CanvasSlots += array
                {
                    canvas_slot:
                        Anchors := CenterAnchors
                        Offsets := margin{Top := YOffset, Left := XOffset, Right := 0.0, Bottom := 0.0}
                        Alignment := CenterVector
                        SizeToContent := true
                        Widget := RewardTextureBlock
                }

                set Index += 1        

        RewardButtonTextureBlockYOffsets : []float = array{ -105.0, 80.0, 275.0 }
        RewardButtonTextureBlockXOffsets : []float = array{ -197.0, -47.0, 107.0, 257.0 }
        set Index = 0
        set GiftImageStartIndex = CanvasSlots.Length
        for (YOffset : RewardButtonTextureBlockYOffsets):
            for (XOffset : RewardButtonTextureBlockXOffsets, RewardButtonTextureBlock := RewardButtonTextureBlocks[Index]):
                set CanvasSlots += array
                {
                    canvas_slot:
                        Anchors := CenterAnchors
                        Offsets := margin{Top := YOffset, Left := XOffset, Right := 0.0, Bottom := 0.0}
                        Alignment := CenterVector
                        SizeToContent := true
                        Widget := RewardButtonTextureBlock
                }

                set Index += 1
        set GiftImageEndIndex = CanvasSlots.Length-1

        RewardTimeTextBlockYOffsets : []float = array{ -188.0, -3.0, 187.0 }
        RewardTimeTextBlockXOffsets : []float = array{ -192.0, -42.0, 108.0, 258.0 }
        set Index = 0
        set GiftTextStartIndex = CanvasSlots.Length
        for (YOffset : RewardTimeTextBlockYOffsets):
            for (XOffset : RewardTimeTextBlockXOffsets, RewardTimeTextBlock := RewardTimeTextBlocks[Index]):
                set CanvasSlots += array
                {
                    canvas_slot:
                        Anchors := CenterAnchors
                        Offsets := margin{Top := YOffset, Left := XOffset, Right := 0.0, Bottom := 0.0}
                        Alignment := CenterVector
                        SizeToContent := true
                        Widget := RewardTimeTextBlock
                }

                set Index += 1
        set GiftTextEndIndex = CanvasSlots.Length-1

        QuitButton : button_quiet = button_quiet{DefaultText := TextForUI("")}
        QuitButton.OnClick().Subscribe(OnQuitButtonClicked)
        set CanvasSlots += array
        {
            canvas_slot:
                Anchors := CenterAnchors
                Offsets := margin{Top:= -303.0, Left:= 354.0, Right := 0.0, Bottom := 0.0}
                Alignment := CenterVector
                SizeToContent := true
                Widget := QuitButton
        }
        
        Canvas : canvas = canvas:
            Slots := CanvasSlots

        return Canvas