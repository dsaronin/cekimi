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

private

  def setup_work()
    Environ.log_info( "starting..." )
    Environ.put_prompt "\t#{ Environ.get_prompt }: merhaba dunia!\n"
  end

  def do_work()
      # command prompt & user input
    begin
      Environ.put_prompt("\n#{ Environ.get_prompt } > ")  
    end    while    parse_commands( Environ.get_input_list )
 
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

        # parse command
    case ( cmdlist.first || ""  ).chomp
      when  "l", "list"      then  do_list      # list rules
      when  "s", "status"    then  do_status    # print status

      when  "f", "flags"     then  do_flags     # print flags
      when  "h", "help"      then  do_help      # print help
      when  "v", "version"   then  do_version   # print version
      when  "o", "options"   then  do_options   # print options

      when  "x", "exit"      then  loop = false  # exit program
      when  "q", "quit"      then  loop = false  # exit program

      when  ""               then  loop = true   # empty line; NOP
      else        
        # treat as cekimi conjugate request
        do_conjugate( cmdlist )
    end

    return loop
                
  end

  def do_list        
  end
  def do_status        
  end
  def do_flags        
  end
  def do_help        
  end
  def do_version        
  end
  def do_options        
  end
  def do_conjugate( list )        
  end



end  # class CekimiWork
