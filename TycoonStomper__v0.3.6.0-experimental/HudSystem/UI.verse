using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using {cc}
using{Super}
<#
█▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▀ █▀▄   █▄▄ █▄█   ▀█▀ █▀ ▄▀█ █▀█
█▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ ██▄ █▄▀   █▄█ ░█░   ░█░ ▄█ █▀█ █▀▄

▄▀█ █░░ █░░   █▀█ █ █▀▀ █░█ ▀█▀ █▀   █▀█ █▀▀ █▀ █▀▀ █▀█ █░█ █▀▀ █▀▄
█▀█ █▄▄ █▄▄   █▀▄ █ █▄█ █▀█ ░█░ ▄█   █▀▄ ██▄ ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▄▀

█▀▄ █▀█   █▄░█ █▀█ ▀█▀   █▀ █▀▀ █░░ █░░
█▄▀ █▄█   █░▀█ █▄█ ░█░   ▄█ ██▄ █▄▄ █▄▄
#>

currency_ui<public>:=class():
    Player<public>:player
    Configs<public>:[]currency_ui_config  
    owner<public>:base


    var canvastodestory:canvas=canvas{}


    var StackBoxHoldings:[]stack_box_slot = array{}



    ManageUI<public>(CAM: [agent]?text_block, ID:?int)<suspends>:void=
        loop:
            Sleep(0.1);
            if:
                ActiveHud := CAM[Player]?
                ParsedID := ID?
                PlayerStats := GetCoreStats[Player, owner.Base_Setup.PersistenceCore]
                PlayerCurrency := PlayerStats.AssociatedCurrencies[ParsedID]
            then:
                ActiveHud.SetText(S2M("{PlayerCurrency.GetTrunc(owner)}"))
            else:
                Print("Unable to attain stats")

            if:
                GetRandomInt(0,100) > 95
            then:
                CurrencyValue()
                #Prints the currency value, done random to not flood logs.

    ManagePS(CAM: []tuple([agent]?text_block, ?int, string))<suspends>:void=
        TotalPS := CAM.Length-1
        var X: int = 0
        loop:
            if:
                ActiveHud := CAM[0](0)[Player]?
                ParsedID := CAM[X](1)?
                Emoji := CAM[X](2)
                PerSecond := owner.MoneyLeague.PerSecond[ParsedID]
            then:
                ActiveHud.SetText(S2M("{Emoji} {PerSecond.GetTrunc(owner)} / sec")) 
            
            if(X = TotalPS){set X = 0}
            else{set X += 1}
            
                
            Sleep(1.85);
            

    Destroy<public>():void=
        if:
            PlayerHud := GetPlayerUI[Player]
        then:
            PlayerHud.RemoveWidget(canvastodestory)





            


    Create<public>():void=
            
        var AddedPS:logic=false
        var PerSecondRotations: []tuple([agent]?text_block, ?int, string) = array{}
        Overlays := for:
            Config:Configs
        do:
            ActiveCash := text_block:
                DefaultText := S2M("0")
                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}

            ActivePS := text_block:
                DefaultText := S2M("")
                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}

            

            var CurrencyAmount: [agent]?text_block = map{}
            if(set CurrencyAmount[Player] = option{ActiveCash}){}
            spawn{ManageUI(CurrencyAmount, Config.CurrencyID)}

            var PerSecond: [agent]?text_block = map{}
            if(set PerSecond[Player] = option{ActivePS}){}
            

            StackWidget := overlay:
                
                
                Slots := array:
                    overlay_slot:
                        Widget := texture_block:
                            DefaultImage := TycoonStomper.StroklessBG
                            DefaultTint := Config.Backgroundcolor
                            DefaultDesiredSize := vector2{X:=32.0, Y:=55.0}
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Right:=5.0}

                    overlay_slot:
                        Widget := text_block:
                            DefaultText := S2M("{Config.Emoji}")
                            DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                        HorizontalAlignment := horizontal_alignment.Left
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Left:=11.0, Right:=35.0}

                    overlay_slot:
                        Widget := text_block:
                            DefaultText := S2M("{Config.AlphaText}")
                            DefaultTextOpacity := Config.AlphaOpcaity
                            DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Left:=11.0, Right:=40.0}

                    overlay_slot:
                        Widget := ActiveCash
                        HorizontalAlignment := horizontal_alignment.Right
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Left:=11.0, Right:=40.0}
            if:
                Config.ShowPerSecond?
                AddedPS?
            then:
                set PerSecondRotations += array{(PerSecond, Config.CurrencyID, Config.Emoji)}
                GlobalSuperlog("Second+ Rev Rotation Added")

            if:
                Config.ShowPerSecond?
                not AddedPS?
            then:
                set AddedPS = true
                set StackBoxHoldings += array:
                    stack_box_slot:
                        Widget := ActivePS
                        HorizontalAlignment := horizontal_alignment.Right
                        VerticalAlignment := vertical_alignment.Bottom
                        Padding:=margin{Right:=40.0}
                set PerSecondRotations += array{(PerSecond, Config.CurrencyID, Config.Emoji)}
                GlobalSuperlog("Initial Rev Rotation Added")
            

                

            
                    
            StackWidget
        GlobalSuperlog("Begun Updating Per Second Rev Rotations") 
        spawn{ManagePS(PerSecondRotations)}
        for:
            Overlay:Overlays
        do:
            set StackBoxHoldings += array:
                stack_box_slot:
                    Widget:=Overlay
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Top

        var FindBottom : float = 80.0 + (125.0*StackBoxHoldings.Length-2.0)

        #Update UI




        #Assign the UI to the player
        CurrencyStackBox:=stack_box:
            Orientation := orientation.Vertical
            Slots:=for:
                Overlay:StackBoxHoldings
            do:
               Overlay
        CanvasPanel:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=CurrencyStackBox
                    Anchors:=anchors{Minimum:=vector2{X:=0.032625,Y:=0.271111}, Maximum:=vector2{X:=0.214375,Y:=0.271111}}
                    Offsets := margin{Bottom := FindBottom}
                    SizeToContent := false
        if:
            PlayerHud := GetPlayerUI[Player]
        then:
            PlayerHud.AddWidget(CanvasPanel)
            set canvastodestory = CanvasPanel

                









            
            




currency_ui_config<public>:=class<public><concrete>():

    @editable CurrencyID : ?int = option{0}
    @editable Emoji : string = "🤑"
    @editable AlphaText : string = "Dollars"
    @editable AlphaOpcaity : type {_X:float where 0.15 <= _X, _X <= 0.85} = 0.75
    @editable ShowPerSecond: logic = false
    @editable Backgroundcolor : color = color{R:=0.000000, G:=0.464583, B:=0.028349}
