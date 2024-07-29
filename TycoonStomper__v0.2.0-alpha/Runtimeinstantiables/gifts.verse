using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}

gift_map := class<concrete>():
    @editable var CurrencyToReceiveID : int = 0
    @editable var GrantAmount : int = 0
    @editable var GrantXPAmount : int = 0
    @editable var OnClaimedMessage: ?string = option{"GIFT CLAIMED :D"}
    @editable var BypassZone: logic = {false}
    
    


unique_giftable<public> := class<concrete><final>(Inaugurable, Hostable):

    #if you arent using the PreMade giftbox.verse file, simply link an OnDurationBought event to your own Gifting system's events.
    #The (int) in the event is the index of the gift you buy.
    #For example playing for X minutes and attaining the first chest you'd signal OnDurationBought(0)

    @editable ReadMe : string = "If you're adding your own gift, \n instructions are in 'Gifts.verse' "

    <#  ------------------------------------------------------------
        THIS CODE IS NOT FOR COMMERCIAL USE
        THIS CODE IS NOT FOR COMMERCIAL USE
        THIS CODE IS NOT FOR COMMERCIAL USE
        THIS CODE IS NOT FOR COMMERCIAL USE
        THIS CODE IS NOT FOR COMMERCIAL USE
        THIS CODE IS NOT FOR COMMERCIAL USE
        #>@editable var Config : giftbox_device = giftbox_device{}
        #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    


    var Owner <public> : base = base{}

    @editable GlobalHudMessageDevice : hud_message_device = hud_message_device{}
    

    @editable DurationsMapToIDAndReward : []gift_map = array
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
        set Config.owner = Hostess
        set Owner = Hostess
        spawn{Host()}

    InitGiftable<public>(P:player):void=
        Config.OnPlayerSpawned(P)
        Config.Initialize(Owner)

    Host<override>()<suspends>:void=
        loop:
            Duration := Config.OnDurationBought.Await()
            
            GlobalSuperlog("Duration received is {Duration}")
            if:
                GlobalSuperlog("Attaining gift to receive")
                GiftToReceive := DurationsMapToIDAndReward[Duration]
            then:
                GlobalSuperlog("Found gift to receive")
                
                for:
                    Player : Owner.Players
                do:
                    if:
                        Message := GiftToReceive.OnClaimedMessage?
                    then:
                        GlobalHudMessageDevice.SetText(S2M("{Message}"))
                        GlobalHudMessageDevice.Show(Player)
                        GrantMoney(Owner, Player, GiftToReceive.CurrencyToReceiveID, GiftToReceive.GrantAmount, GiftToReceive.BypassZone)
                        GrantXP(Owner, Player, GiftToReceive.GrantXPAmount)

            else:
                GlobalSuperlog("No gift to receive")


                


