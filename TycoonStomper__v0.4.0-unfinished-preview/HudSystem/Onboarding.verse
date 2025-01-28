using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using{TutorialSeriesV0_1}
using {cc}
using{Super}
using{Stomper}
<#
█▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▀ █▀▄   █▄▄ █▄█   ▀█▀ █▀ ▄▀█ █▀█
█▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ ██▄ █▄▀   █▄█ ░█░   ░█░ ▄█ █▀█ █▀▄

▄▀█ █░░ █░░   █▀█ █ █▀▀ █░█ ▀█▀ █▀   █▀█ █▀▀ █▀ █▀▀ █▀█ █░█ █▀▀ █▀▄
█▀█ █▄▄ █▄▄   █▀▄ █ █▄█ █▀█ ░█░ ▄█   █▀▄ ██▄ ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▄▀

█▀▄ █▀█   █▄░█ █▀█ ▀█▀   █▀ █▀▀ █░░ █░░
█▄▀ █▄█   █░▀█ █▄█ ░█░   ▄█ ██▄ █▄▄ █▄▄
#>

onboarding_ui<public>:=class(Runtime):

    Owner<public>:tycoon_stomper

    OnBegin<override>(IX:int):void=
        if:
            UIPlayer := Owner.GetPlayspace().GetPlayers()[0]
            PlayerUI := GetPlayerUI[UIPlayer]
        then:
            BuildAndGenerateCanvas(UIPlayer, PlayerUI)

    BuildAndGenerateCanvas(Player:player, PlayerUI:player_ui):void=
        CloseButton:=button_quiet{DefaultText:=S2M("CLOSE")}
        ViewMoreButton:=button_quiet{DefaultText:=S2M("VIEW MORE")}
        Main:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=texture_block{DefaultImage:=WelcomeBanner, DefaultDesiredSize:=vector2{X:=1920.0,Y:=1080.0}}
                    SizeToContent:=true
                canvas_slot:
                    Widget:=stack_box
                    {
                        Orientation:=orientation.Horizontal
                        Slots:=array:
                            stack_box_slot:
                                Widget:=CloseButton
                                HorizontalAlignment:=horizontal_alignment.Fill
                                Distribution:=option{1.0}
                                
                            stack_box_slot:
                                Widget:=ViewMoreButton
                                HorizontalAlignment:=horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Distribution:=option{1.0}
                    }
                    Anchors:=anchors{Minimum:=vector2{X:=0.5, Y:=0.9}, Maximum:=vector2{X:=0.5, Y:=0.9}}
                    Offsets:=margin{Left:=-516.0, Top:=-16.0, Right:=1034.5, Bottom:=85.0}
                    SizeToContent:=false
        PlayerUI.AddWidget(Main, Slot:=player_ui_slot{InputMode:=ui_input_mode.All})
        spawn. AwaitClose(CloseButton, Main, PlayerUI)
        spawn. AwaitViewMore(ViewMoreButton, Main, PlayerUI)



    AwaitClose(Button:button_quiet, MainCanvas:canvas, PlayerUI:player_ui)<suspends>:void={
            Button.OnClick().Await(); Sleep(0.0)
            PlayerUI.RemoveWidget(MainCanvas)
    }

    AwaitViewMore(Button:button_quiet, MainCanvas:canvas, PlayerUI:player_ui)<suspends>:void={
            Button.OnClick().Await(); Sleep(0.0)
            PlayerUI.RemoveWidget(MainCanvas)
    }

        

            



    




    