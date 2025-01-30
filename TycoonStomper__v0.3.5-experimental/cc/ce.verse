using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
<#

░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗
██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║
██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║
██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║
╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║
░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝

███████╗███╗░░██╗██╗░░░██╗███╗░░░███╗░██████╗░░░██╗░░░██╗███████╗██████╗░░██████╗███████╗
██╔════╝████╗░██║██║░░░██║████╗░████║██╔════╝░░░██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝
█████╗░░██╔██╗██║██║░░░██║██╔████╔██║╚█████╗░░░░╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░
██╔══╝░░██║╚████║██║░░░██║██║╚██╔╝██║░╚═══██╗░░░░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░
███████╗██║░╚███║╚██████╔╝██║░╚═╝░██║██████╔╝██╗░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗
╚══════╝╚═╝░░╚══╝░╚═════╝░╚═╝░░░░░╚═╝╚═════╝░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝

#>
AnimationStyle <public> := enum:
    none
    Grouped
    LegoLike
    
LogicalVisibilityStatus <public> := enum:
    Shown
    Hidden

LogicalStatus  <public> := enum:
    Enabled
    Disabled
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

PropMovementType  <public> := enum:
    Nothing
    Show_When_Enough
    Hide_When_Enough
    Show_When_Not_Enough
    Hide_When_Not_Enough
PurchaseMovementType <public> := enum:
    Nothing
    Show
    Hide

ClaimFauilreReason <public> := enum:
    TooManyPlayers
    AlreadyOwnsBase


(Status:ClaimFauilreReason).ToStr<public>()<transacts>:string=
    case(Status):
        ClaimFauilreReason.TooManyPlayers => return "This base is already claimed by other player(s)"

        ClaimFauilreReason.AlreadyOwnsBase => return "You Already Own A Base"


(Status:PurchaseableType).ToStr<public>()<transacts>:string=
    case(Status):
        PurchaseableType.Undefined => return "Undefined"

        PurchaseableType.BasicProp => return "BasicProp"

        PurchaseableType.Conveyor => return "Conveyor"

        PurchaseableType.Dropper => return "Dropper"

        PurchaseableType.NPCBuyable => return "NPCBuyable"

        PurchaseableType.Shootable => return "Shootable"

        PurchaseableType.Hitable => return "Hitable"

        PurchaseableType.DanceFloor => return "DanceFloor"

        PurchaseableType.Pet => return "Pet"

PurchasedStatus  <public> := enum:
    Purchased
    NotPurchased

(Status:PurchasedStatus).ToStr<public>()<transacts>:string=
    case(Status):
        PurchasedStatus.Purchased => return "Purchased"

        PurchasedStatus.NotPurchased => return "Not Purchased"



#Defines the status of a base.
ClaimStatus<public> := enum:
    Claimed
    Unclaimed

(Status:ClaimStatus).ToStr<public>()<transacts>:string=
    case(Status):
        ClaimStatus.Claimed => return "Claimed"

        ClaimStatus.Unclaimed => return "Unclaimed"