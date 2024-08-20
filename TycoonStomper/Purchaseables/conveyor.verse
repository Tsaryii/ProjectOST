using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com}
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}
conveyor_buyable<public> := class<concrete><final>(purchaseable):

    @editable var ConveyorConfig <public>: unique_conveyor = unique_conveyor{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.Conveyor

    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)
        
        #Lists out all the properties of the item
        Detail("ConveyorBuyable")
    Host<override>():void={}
conveyor_prop := class<unique>():

    
    #Defines the coordinates of the conveyor belt
    var endcoord: vector3 = vector3{}

    #Defines the time it takes for the prop to move from start to end
    var MoveTime : float = 5.0
    var Speed : float = 100.0

    var ReachedEnd : event() = event(){}

    var HostProp:creative_prop_asset

    Initialize(parsedcoord:vector3, speed:float)<suspends>:void=
        set endcoord = parsedcoord
        set Speed = speed

    InagurateMove(startcoord:vector3)<suspends>:void=
        set MoveTime = Distance(startcoord, endcoord) / Speed
        PropToMove := SpawnProp(HostProp, startcoord, rotation{})
        if:
            prop := PropToMove(0)?
        then:
            MVT := prop.MoveTo(endcoord, prop.GetTransform().Rotation, MoveTime)
            if:
                MVT = move_to_result.DestinationReached
            then:
                Sleep(0.1)
                ReachedEnd.Signal()
                GlobalSuperlog("Reached end signal")
                prop.Dispose()
unique_conveyor<public> := class<concrete>():

    @editable var ConveyorEnd : vector3 = vector3{}
    @editable var ConveyorSpeed : float = {100.0}

    
    Register(Prop:conveyor_prop):void=
        spawn{Prop.Initialize(ConveyorEnd, ConveyorSpeed)}


            