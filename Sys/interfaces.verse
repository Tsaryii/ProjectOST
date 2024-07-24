using { /Verse.org/Simulation }
Iinitialize<public>:=interface():

    Initialize<public>():initialization_result

Itoggle<public>:=interface():

    Enable<public>():toggle_result

    Disable<public>():toggle_result

Iruntime<public>:=interface():

    rt_init<public>()<suspends>:void
