using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}

unique_moneywheel<public> := class<concrete><final>(Inaugurable, Hostable):

    #if you arent using the PreMade SpinningWheel.verse file simply link a OnSpin event to your own Gifting system.
    #The (int) in the event is the random wheel result.


    @editable ReadMe : string = "If you're adding your own moneywheel, \n instructions are in 'moneywheel.verse' "

    @editable MoneyWheelDevice : SpinningWheel = SpinningWheel{}

    var Owner <public> : base = base{}

    @editable MoneyWheelRand : []gift_map = array
    {
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=100, GrantXPAmount:=50}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=250, GrantXPAmount:=100}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=500, GrantXPAmount:=250}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=750, GrantXPAmount:=500}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=1500, GrantXPAmount:=1000}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=2000, GrantXPAmount:=1500}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=2500, GrantXPAmount:=2000}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=4000, GrantXPAmount:=3000}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=5000, GrantXPAmount:=4000}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=7500, GrantXPAmount:=5000}
        gift_map{CurrencyToReceiveID:=0, GrantAmount:=10000, GrantXPAmount:=7500}
    }
    

    Initialize<override>(Hostess:base):void=
        set Owner = Hostess
        spawn{Host()}
    

    Host<override>()<suspends>:void=
        loop:
            Duration := MoneyWheelDevice.OnSpin.Await()
            if:
                GiftToReceive := MoneyWheelRand[Duration]
            then:
                for:
                    Player : Owner.Players
                do:
                    GrantMoney(Owner, Player, GiftToReceive.CurrencyToReceiveID, GiftToReceive.GrantAmount, false)
                    GrantXP(Owner, Player, GiftToReceive.GrantXPAmount)
            else:
                GlobalSuperlog("Moneywheel gave an invalid result")