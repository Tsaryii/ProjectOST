using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com}
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}
npc_buyable<public>:=class<concrete><final>(purchaseable):

    @editable var NPCSpawnerConfig : unique_npc_spawner = unique_npc_spawner{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.NPCBuyable
    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)

        #Initalizes all the NPC spawners
        NPCSpawnerConfig.Initialize(Hostess)
        
        #Lists out all the properties of the item
        Detail("NPCBuyable")
        
    #Hosts the NPC spawner when the item is bought and grants the player money when the NPC is killed
    Host<override>()<suspends>:void=
        NPCSpawnerConfig.Enable()
        loop:
            Agent := NPCSpawnerConfig.OnKill.Await()
            if:
                Player := player[Agent]
                Granter := NPCSpawnerConfig.OptItemGranter?
            then:
                GrantMoney(Owner, Player, NPCSpawnerConfig.CurrencyOnKillID, NPCSpawnerConfig.OnKillGrantAmount, BypassZone)
                GrantXP(Owner, Player, NPCSpawnerConfig.OnKillExperienceAmount)
                Granter.GrantItem(Player)
                HudConfig.OnSuccessfullPlayer(Player)
            
        
unique_npc_spawner<public>:=class<concrete>(Toggleable, Inaugurable):
    @editable var NPCSpawner : npc_spawner_device = npc_spawner_device{}
    @editable var CurrencyOnKillID  : int = {0}
    @editable var OnKillGrantAmount : int = {0}
    @editable var OnKillExperienceAmount : int = {0}
    @editable var OptItemGranter : ?item_granter_device = option{item_granter_device{}}
    
    OnKill : event(agent) = event(agent){}

    Disable<override>():void={NPCSpawner.Disable()}
    Enable<override>():void={NPCSpawner.Enable()}

    Initialize<override>(Base:base):void={NPCSpawner.Disable(); spawn{AwaitKill()}}

    AwaitKill()<suspends>:void=
        loop:
            Sleep(0.0)
            InteractionResult := NPCSpawner.EliminatedEvent.Await()
            if:
                Agent := InteractionResult.Source?
            then:
                OnKill.Signal(Agent)
                






