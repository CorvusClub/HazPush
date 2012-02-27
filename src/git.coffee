fs = require 'fs'
exec = require('child_process').exec
validator = require('validator').sanitize

Git = (dir) ->
	@submodules = false
	try
		@git_dir = fs.realpathSync dir
		process.chdir @git_dir
		console.log process.cwd()
		
		config = fs.readFileSync "#{@git_dir}/.git/config", 'utf8'
		@submodules = true if config.match /^\[submodule "[\w\d]+"\]/m
		
		
	catch error
		console.log 'error: '+error
		process.exit(1)
		
	return this

Git.create = (dir)->
	new Git dir


Git.prototype.status = (callback) ->
	status = exec "/usr/bin/env git status -s", (error, stdout, stderr) ->
		clean = validator(stdout).trim()
		
		cambios = []
		cambios = clean.split '\n' if clean.length isnt 0 
		callback cambios


Git.prototype.pull = (callback, repo='origin', branch='master') ->
	exec "/usr/bin/env git submodule update" if @submodules is true
	
	this.status (cambios)->
		console.log cambios
		if cambios.length>0
			callback {"error": true, "because": "Branch '#{branch}' has unstaged changes.", "changes": cambios}
		else
			status = exec "/usr/bin/env git pull #{repo} #{branch}", (error, stdout, stderr) ->
				ret = validator(stdout).trim()
				if ret is 'Already up-to-date.'
					callback {"error": true, "because": "Branch '#{branch}' is already up to date."}
				else
					callback stdout
	

module.exports = Git