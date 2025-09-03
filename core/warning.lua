function warn(msg)
	printJson(toJson{
		text="[!] "..msg.."\n",
		color="yellow"
	})
end