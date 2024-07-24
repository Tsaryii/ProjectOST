using{Base}
using{Sys}
using {/Verse.org/Simulation}


purchaseable<public>:=class<abstract><unique>(Iinitialize):

    var ccBase <protected> : base = base{}
    var ItemType <public> : item_type = item_type.purchaseable

    @editable var Name <public> : string = ""
    @editable var Description <public> : string = ""
    @editable var Price <public> : cost_type = cost_type{currencyid:=0, value:=0}
    @editable var GrantAmount <public> : cost_type = cost_type{currencyid:=0, value:=10}
    @editable var PurchaseVolume <public> : cd_volume = cd_volume{}
    @editable var GrantInterval <public> : float = 1.0



    Initialize<override>():initialization_result=
        PurchaseVolume.rt_init
        initialization_result.initialized
    
cost_type <public> := class<concrete>():
    @editable currencyid <public> : int = 0
    @editable value <public> : int = 0



