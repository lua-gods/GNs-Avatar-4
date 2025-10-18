function warn(msg)
	printJson(toJson{
		text="\n[!] "..msg.."\n",
		color="yellow"
	})
end