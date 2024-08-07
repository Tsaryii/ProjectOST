using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
#███████╗███╗░░██╗██╗░░░██╗███╗░░░███╗░██████╗
#██╔════╝████╗░██║██║░░░██║████╗░████║██╔════╝
#█████╗░░██╔██╗██║██║░░░██║██╔████╔██║╚█████╗░
#██╔══╝░░██║╚████║██║░░░██║██║╚██╔╝██║░╚═══██╗
#███████╗██║░╚███║╚██████╔╝██║░╚═╝░██║██████╔╝
#╚══════╝╚═╝░░╚══╝░╚═════╝░╚═╝░░░░░╚═╝╚═════╝░
AnimationStyle <public> := enum:
    Grouped
    LegoLike
    LegoLike5x
    

LogicalStatus  <public> := enum:
    Enabled
    Disabled
PAnimation  <public> := enum:
    SlowFadeIn
    FadeIn
    FastFadeIn
Dependency  <public> := enum:
    Locked
    Unlocked
PurchaseableType  <public> := enum<persistable>:
    Undefined
    BasicProp
    Conveyor
    Dropper
    NPCBuyable
    Shootable
    Hitable
    DanceFloor
    Pet

PurchasedStatus  <public> := enum:
    Purchased
    NotPurchased