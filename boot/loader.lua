-- we use this so we know where we are
-- the parent of this dir should be the root of the boot drive
local parentDir = debug.getinfo(1).source:match("@?(.*/)")
local bootFile = ""
local function boot(kernel,timeout,name,...)
	term.write("boot:")
	parallel.waitForAny(function()
		while true do
			local _, key = os.pullEvent("key")
			if key == keys.enter then
				break
			end
		end
	end,
	function()
		sleep(tonumber(timeout))
	end)
	term.setCursorPos(1,2)
	term.write("Loading "..kernel)
	local loadedKernel
	parallel.waitForAny(function()
		while true do
			term.write(".")
			sleep()
		end
	end,
	function()
		loadedKernel = loadfile(kernel)
	end)
	print("")
	print("Running file")
	local success, response = pcall(loadedKernel,...)
	if not success then
		printError(response)
	end
	while true do
		sleep() 
	end
end
local function startBoot(bootDrive,version)
	term.write("L")
	if not fs.exists(parentDir.."/map.json") then
		while true do
			sleep()
		end
	end
	if parentDir:sub(1,#bootDrive) ~= bootDrive then
		term.write("?") --something isnt right
		while true do
			sleep()
		end
	end
	local file = fs.open(parentDir.."map.json", "r")
	if file == nil then
		term.write("-") --for some reason the file isnt accessible
		while true do
			sleep()
		end
	end
	local descriptor = textutils.unserialiseJSON(file.readAll())
	if descriptor == nil or descriptor.bootfile == nil or descriptor.args == nil or descriptor.timeout == nil or descriptor.name == nil then
		term.write("-") --json is nil
		while true do
			sleep()
		end
	end
	file.close()
	term.write("O")
	term.write(" "..version.." ")
	boot(bootDrive..descriptor.bootfile,descriptor.timeout,descriptor.name,table.unpack(descriptor.args))
end
if #{...} ~= 0 then
	startBoot(...)
else
	while true do
		sleep()
	end
end