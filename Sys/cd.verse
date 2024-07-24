using { /Fortnite.com/Devices }
using { /Verse.org/Concurrency }
using { /Verse.org/Simulation }
cd := class<abstract>(Itoggle, Iruntime):
    var active <protected> : logic = false
    
    

    Enable<override>():toggle_result=
        if(active?):
            toggle_result.unchanged
        else:
            set active = true
            toggle_result.changed       
        
    
    Disable<override>():toggle_result=
        if(active?):
            set active = false
            toggle_result.changed
        else:
            toggle_result.unchanged

    

    
    



cd_volume <public> := class<concrete>(cd):
    
    @editable device <public>  :  volume_device = volume_device{}
    AgentEntersEvent <public>  :  event(agent) = event(agent){}
    AgentExitsEvent  <public>  :  event(agent) = event(agent){}

    rt_init<override>()<suspends>: void =
        loop:
            race:
                block:
                    Agent := device.AgentEntersEvent.Await()
                    if. active? then. AgentEntersEvent.Signal(Agent)
                block:
                    Agent := device.AgentExitsEvent.Await()
                    if. active? then. AgentExitsEvent.Signal(Agent)
                    
                    
                    
                                
                    
    




    
