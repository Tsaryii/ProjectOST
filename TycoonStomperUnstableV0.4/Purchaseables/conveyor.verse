using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}

purchaseable_conveyor<public>:=class<concrete>(purchaseable):

    var Ptype <override> :  PurchaseableType = PurchaseableType.Conveyor


    @editable ConveyorConfig <public> : custom_conveyor = custom_conveyor{}


    #Initializes the item
    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method and waits for it to finish
        (super:)Initialize(Hostess, I)


        if.  Owner := MaybeOwner?
        then. ConveyorConfig.Initialize(Owner)
        
        #Lists out all the properties of the item
        Detail("conveyor")

        


    #Runs after the item is bought
    Host<override>()<suspends>:void={ConveyorConfig.OnBegin()}
        