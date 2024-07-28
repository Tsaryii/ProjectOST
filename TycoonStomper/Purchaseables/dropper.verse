using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

    unique_dropper<public> := class<concrete>():

        @editable var ConveyorID : int = {0}
        @editable var RewardID: int = {0}
        @editable var RewardAmount: int = {0}
        @editable var Prop: creative_prop_asset = DefaultCreativePropAsset
        @editable var SpawnInterval : ?float = option{5.0}
        @editable var StartLocation : vector3 = vector3{}






    dropper_buyable<public> := class<concrete><final>(purchaseable):

        @editable var DropperConfig : unique_dropper = unique_dropper{}
        var Ptype <override> :  PurchaseableType = PurchaseableType.Dropper


        var ConveyorProp : conveyor_prop = conveyor_prop{HostProp:=DefaultCreativePropAsset}


        Initialize<override>(Hostess:base, I:int):void=
            #Calls the parent class's Initialize method
            (super:)Initialize(Hostess, I)
            spawn{Reward(Hostess)}


            #Lists out all the properties of the item
            Detail("DropperBuyable")

            #Registers the conveyor prop
            if:
                ConveyorHost := GetConveyorConfig[Hostess, DropperConfig.ConveyorID]
                set ConveyorProp = conveyor_prop{HostProp:=DropperConfig.Prop}
            then:
                ConveyorHost.Register(ConveyorProp)

        #Hosts the dropper by managing when its prop moves.
        Host<override>()<suspends>:void={
            loop:
                if:
                    SP := DropperConfig.SpawnInterval?
                    SP >= 0.011
                then:
                    Sleep(SP)
                    ConveyorProp.InagurateMove(DropperConfig.StartLocation)
                else:
                    ConveyorProp.ReachedEnd.Await()
                    ConveyorProp.InagurateMove(DropperConfig.StartLocation)
                Sleep(0.0);


        }
        Reward(Hostess:base)<suspends>:void={
            loop:
                ConveyorProp.ReachedEnd.Await()

                #Grant money to all players who are in the base 
                for:
                    Player : Hostess.Players
                do:
                    GrantMoney(Hostess, Player, DropperConfig.RewardID, DropperConfig.RewardAmount)
        }


