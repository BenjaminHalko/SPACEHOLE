
function FirebaseREST_HTTP_Success_RealTime()
{
    switch(event)
	{
		default:
			FirebaseREST_asyncCall_RealTime()
		break

		////////////////////////////////////////////////REALTIME DATABASE
		
		case "FirebaseRealTime_Listener":
		case "FirebaseRealTime_Read":
			if(async_load[?"result"] == "null")
				FirebaseREST_asyncCall_RealTime(undefined)
			else
			{
				try {
					var value = json_parse(async_load[?"result"])
					if(is_struct(value))
						value = json_stringify(value)
					FirebaseREST_asyncCall_RealTime(value)
				} catch(_e) {
					show_debug_message(_e);
					global.noInternet = true;
					global.username = "Player 1";
				}
			}
		break
        
	    case "FirebaseRealTime_Exists":
			if(async_load[?"result"] == "null")
				FirebaseREST_asyncCall_RealTime(false)
			else
				FirebaseREST_asyncCall_RealTime(true)
	    break
		
	}
}
