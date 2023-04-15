# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class CekimiWork -- main work module for doing everything
#

class CekimiWork
  require_relative 'environ'

  def initialize()
    @my_env = Environ.instance
  end

  def cekimi()
    setup_work()
    do_work()      # do the work of çekimi
    shutdown_work()

    return 1
  end

  def setup_work()
    Environ.log_info( "starting..." )
    Environ.put_prompt "\tçekimi: merhaba dunia!\n"
  end

  def do_work()
      # command prompt
    Environ.put_prompt("${getPrompt()} > ")  until 
      parse_commands( Environ.get_command_line )
 
  end

  def shutdown_work()
    Environ.log_info( "...ending" )
  end

  # parse_commands -- parses the command string and executes commands
  # args:
  #   cmdlist: array of syntatical elements
  # returns boolean: true if continue looping
  def parse_commands( cmdlist )        
        loop = true                 # user input loop while true
        dropCount = 1               # assume need to drop cmd from list head

        # parse command
        when ( cmd = cmdlist.first().trim() ) {
            # list rules
            "list"  -> 
            "l"     -> 


            # status
            "sts", "status" -> 
            "s"   -> 

            "f", "flags"     -> 
            "h", "help"      -> 
            "v", "version"   -> 
            "o", "options"   -> 

            "x", "ex", "exit"       -> loop = false   # exit program
            "q", "quit"             -> loop = false  # exit program

            ""               -> loop = true   # empty line; NOP
            else        ->   # treat as cekimi conjugate request
        }

        # useKamusi will be non-null if a search command was encountered
        # searchKeyList( cmdlist.drop(dropCount) )   # conjugate

        return loop
                
  end


end  # class CekimiWork
