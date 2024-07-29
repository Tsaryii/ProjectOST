using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

SpinningWheel := class(creative_device):
    #Editables
    @editable Wheel : creative_prop = creative_prop{}
    @editable Button : button_device = button_device{}
    @editable LootGranters : []item_granter_device = array{}
    OnSpin : event(int) = event(int){}
    #Varubles
    var Rotates : logic = false
    var Degrees :[]float = array{0.0, 30.0, 60.0, 90.0, 120.0, 150.0, -180.0, -150.0, -120.0, -90.0, -60.0, -30.0}
    var RandInt : int = 0
    var RotatingDegrees : float = 30.0
    var Speed : float = 0.2
    var Delay : int = 15

    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnButtonClicked)

    OnButtonClicked(Agent : agent):void=
        if(not Rotates?):
            set RandInt = GetRandomInt(0,Degrees.Length -1)
            if(Angle := Degrees[RandInt]):
                spawn {MakeWheelSpin(Agent,Angle)}

    MakeWheelSpin(Agent:agent,Angle:float)<suspends>:void=
        set Rotates = true
        var CurrentSpeed : float = Speed
        var CurrentDelay : int = Delay
        loop:
            Transform := Wheel.GetTransform()
            Position := Transform.Translation
            Rotation := Transform.Rotation
            NewRotation := Rotation.ApplyRoll(DegreesToRadians(RotatingDegrees))
            Wheel.MoveTo(Position,NewRotation,CurrentSpeed)
            if (CurrentDelay <= 0):
                if (CurrentSpeed <  0.35):
                    set CurrentSpeed += 0.05
                WheelCurrentRotation : []float = Wheel.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (CurrentAngle := WheelCurrentRotation[2]):
                    ("Current Agle is : {CurrentAngle}/{Angle}")
                    if(RoundedCurrentAngle := Round[CurrentAngle]*1.0):
                        if(RoundedCurrentAngle < Angle + 10.0 and RoundedCurrentAngle > Angle - 10.0):
                            set Rotates = false
                            GrantItem(Agent)
                            break

            else:
                set CurrentDelay -= 1
            Sleep(0.0)

    GrantItem(Agent:agent):void=
        if(Item := LootGranters[RandInt]):
            Item.GrantItem(Agent)
        OnSpin.Signal(RandInt)
