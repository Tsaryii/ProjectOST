using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Concurrency }
using {cc}

purchaseable_upgrader<public>:=class<concrete>(purchaseable):

    var Ptype <override> :  PurchaseableType = PurchaseableType.Upgrader

    @editable WaypointableConfig : custom_dropper = custom_dropper{Type := types.upgrader}
    @editable var LocationalConfig      <public> :  custom_waypointable_config = custom_waypointable_config{}

    var iWaypoint : ?waypoint = false
    

    #Initializes the item
    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method and waits for it to finish
        (super:)Initialize(Hostess, I)
        
        #Lists out all the properties of the item
        Detail("purchaseable_waypointable")

        WaypointableConfig.Initialize(Self)


    
    

    
    #Runs after the item is bought
    Host<override>()<suspends>:void=
        var S:int = 1

        
        block:
            if:
                Owner := MaybeOwner?
                Conveyor := GetConveyorConfig[Owner, LocationalConfig.ConveyorID]
                Waypoint := Conveyor.ConveyorWaypoints[LocationalConfig.WaypointID]
            then:
                Waypoint.Link(WaypointableConfig)
                set iWaypoint = option{Waypoint}
        return

    OnRebirth<override>():void=
        (super:)OnRebirth()

        if:
            Waypoint := iWaypoint?
        then:
            Waypoint.Unlink(WaypointableConfig)
            set iWaypoint = {false}

    


        
