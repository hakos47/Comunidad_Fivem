Config = {}

Config.genericAdminActions = {
	export = function(entity, action)
				TriggerServerEvent(
			        "exportEntity",
			        entity.target,
			        entity.type,
			        entity.hash,
			        entity.modelName,
			        entity.coords,
			        entity.heading,
			        entity.rotation)
			end,
	examine = function(entity, action)
				examine()
			end
}


Config.subMenuInfo = {
	dardinero = {
		label = "💲 Dar dinero ",
		color = "green"
	},
	police = {
		label = "Policia",
		color = "blue"
	},
	police_objects = {
		label = "Colocar Objetos",
		color = "blue"
	},
	mechanic = {
		label = "🧑‍🔧-Mecanico",
		color = "orange"
	},
	ambulance = {
		label = "UMC",
		color = "green"
	},
	taxi = {
		label = "Taxi",
		color = "yellow"
	},
	cardealer = {
		label = "Concesionario",
		color = "brown"
	},
	garbage = {
		label = "Basurero",
		color = "lightgrey"
	},
	cityworks = {
		label = "Mantenimiento",
		color = "lightgrey"
	},
	interaction = {
		label = "Interactuar",
		color = "purple"
	},
	utilities = {
		label = "Utilidades",
		color = "lightBlue"
	},
	vehicle_actions = {
		label = "Acciones",
		color = "lightBlue"
	},
	vehicle_doors = {
		label = "Puertas",
		color = "lightGreen"
	},
	illegal = {
		label = "Acciones Ilegales",
		color = "red"
	}
}




--------------------------------------------------------------------------------------

								--OBJECTS ACTIONS--

--------------------------------------------------------------------------------------

Config.trashHashes = {
	218085040,
    -58485588,
    856312526,
    1387151245,
    -1211968443,
    -206690185,
    -1426008804,
    1143474856,
    1437508529,
    1138027619,
    -1096777189,
    -468629664,
    -939897404,
    1614656839,
    143291855,
    1329570871,
    -515278816,
    -14708062,
    811169045,
    -2096124444,
    -130812911,
    1748268526,
    -1605769687,
    388197031,
    666561306,
    682791951
}



Config.possibleActionsObjects = {
	
	--cajeros de pasta
	usar_cajero = {
		action = function(entity, action)
			ExecuteCommand('atm')
		end,
		hashes = {
			506770882, 
			-1364697528, 
			-870868698, 
			-1126237515
		},
		label = "usar cajero",
		actionDistance = 1.75,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},

}









--------------------------------------------------------------------------------------

								--NPC ACTIONS--

--------------------------------------------------------------------------------------









Config.genericNpcActions = {
	sellDrugs = {
		subMenu = "illegal",
		action = function(entity, action)
			print "en desarrollo"
		end,
		label = "ofrecer drogas",
		actionDistance = 2.5,
		restrictedJobs = {"police", "offpolice", "mechanic", "ambulance", "taxi", "cardealer"}
	},
}

Config.possibleActionsNpc = {
	--DAR DINERO
	dar50 = {
		subMenu = "dardinero",
		action = function(entity, action)
			print "en desarrollo"
        end,
        hashes = Config.darDineroNPCsList,
		label = "Dar 50 💲",
		actionDistance = 2.5,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},
	dar100 = {
		subMenu = "dardinero",
		action = function(entity, action)
			print "en desarrollo"
        end,
        hashes = Config.darDineroNPCsList,
		label = "Dar 100 💲",
		actionDistance = 2.5,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},
	dar500 = {
        hashes = Config.darDineroNPCsList,
		subMenu = "dardinero",
		action = function(entity, action)
			print "en desarrollo"
		end,
        label = "Dar 500 💲",
        --hashes = darDineroNPCsList,
		actionDistance = 2.5,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},

	--FIN DAR DINERO--
}





--------------------------------------------------------------------------------------

								--PLAYER ACTIONS--

--------------------------------------------------------------------------------------





Config.playerActions = {
	-- DAR DINERO
	dar50 = {
		subMenu = "dardinero",
		action = function(entity, action)
			print "en desarrollo"
		end,
		label = "Dar 50€",
		actionDistance = 2.3,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},
	dar100 = {
		subMenu = "dardinero",
		action = function(entity, action)
			print "en desarrollo"
		end,
		label = "Dar 100€",
		actionDistance = 2.3,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},
	dar500 = {
		subMenu = "dardinero",
		action = function(entity, action)
			print "en desarrollo"
		end,
		label = "Dar 500€",
		actionDistance = 2.3,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},
	
	cargar = {
		subMenu = "interaction",
		action = function(entity, action)
			print "en desarrollo"
		end,
		label = "Cargar",
		actionDistance = 1.3,
		restrictedJobs = nil,
		whiteListedJobs = nil,
		entityCoords = nil
	},

}