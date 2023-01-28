global function RGBModSettingsInit

void function RGBModSettingsInit()
{
	AddModTitle("Provoxin RGB")

	AddModCategory( "Colors" )

	AddModSettingsRGBColorPicker( "idcolor_ally", "rgb_ally_color", "Friendly Color" )
	AddModSettingsRGBColorPicker( "idcolor_enemy", "rgb_enemy_color", "Enemy Color" )

	AddConVarSettingSlider( "rgb_ally_brightness", "Brightness", 0, 50, 0.1, true )

	AddConVarSettingSlider( "rgb_enemy_brightness", "Brightness", 0, 50, 0.1, true )

	AddModCategory("Colour Cycling Settings")

	AddModSettingsDropDown( "rgb_ally_rainbow", "Ally Rainbow Cycle", [ "Disabled", "Enabled" ], true )
	AddModSettingsDropDown( "rgb_enemy_rainbow", "Enemy Rainbow Cycle", [ "Disabled", "Enabled" ], true )
	AddConVarSetting("rgb_cycle_speed", "Colour cycling speed", "float")
}

void function AddModSettingsRGBColorPicker( string conVar, string archive, string buttonLabel, bool liveUpdate = false )
{
	AddModSettingsButton( buttonLabel,
		void function() : ( conVar, archive )
		{
			thread void function() : ( conVar, archive )
			{
				EndSignal( uiGlobal.signalDummy, "ColorPickerSelected" )
				OpenColorPickerDialog( conVar, false, false, false )
				OnThreadEnd( void function()
					{
						CloseSubmenu()
					}
				)
				while( true )
				{
					table response = WaitSignal( uiGlobal.signalDummy, "ColorPickerLiveUpdate", "ColorPickerDialogReset" )
					int cbMode = GetConVarInt( "colorblind_mode" )
					string conVarSuffix = cbMode != 0 ? "_cb" + cbMode : ""

					printt( response )

					if( response.signal == "ColorPickerDialogReset" )
					{
						SetConVarToDefault( conVar + conVarSuffix )
						SetConVarToDefault( archive )
						return
					}

					vector ornull rgb = expect vector ornull( response[ "color" ] )
					if( rgb == null )
						continue
					expect vector( rgb )

					SetConVarString( conVar + conVarSuffix, format( "%.1f %.1f %1.f %s", rgb.x / 255, rgb.y / 255, rgb.z / 255, GetConVarString( "rgb_ally_brightness" ) ) )
					SetConVarString( archive, format( "%.1f %.1f %1.f", rgb.x / 255, rgb.y / 255, rgb.z / 255 ) )
				}
			}()
		}, 3
	)
}