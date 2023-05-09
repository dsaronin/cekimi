# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class CekimiWork -- main work module for doing everything
#

class CekimiWork
  require_relative 'environ'
  require_relative 'cekimi_rules'
  require_relative 'verb'

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  STARTING_RULE  = "aorist"   # starting point for conjugations
 
  #  ------------------------------------------------------------
  #  initialize  -- creates a new object
  #  ------------------------------------------------------------
  def initialize()
    
    @my_env = Environ.instance
    @my_rules = CekimiRules.new
    @main_rule = STARTING_RULE
  end

  #  ------------------------------------------------------------
  #  initialize  -- creates a new cekimi system work object
  #  ------------------------------------------------------------
  def cekimi()
    setup_work()
    do_work()      # do the work of çekimi
    shutdown_work()

    return 1
  end

private

  #  ------------------------------------------------------------
  #  setup_work  -- handles initializing cekimi system
  #  ------------------------------------------------------------
  def setup_work()
    Environ.log_info( "starting..." )
    Environ.put_message "\n\t#{ Environ.app_name }: otomatik fiil çekimi yazılımı; İstemde bir fiil girin.\n"
  end

  #  ------------------------------------------------------------
  #  do_work  -- handles primary cekimi stuff
  #  ------------------------------------------------------------
  def do_work()
      # loop for command prompt & user input
    begin
      Environ.put_prompt("\n#{ Environ.app_name } > ")  
    end    while    parse_commands( Environ.get_input_list )
 
  end

  #  ------------------------------------------------------------
  #  shutdown_work  -- handles pre-termination stuff
  #  ------------------------------------------------------------
  def shutdown_work()
    Environ.log_info( "...ending" )
  end

  #  ------------------------------------------------------------
  #  parse_commands -- parses the command string and executes commands
  #  ------------------------------------------------------------
  #  args:
  #   cmdlist: array of syntatical elements
  #  returns boolean: true if continue looping
  #  ------------------------------------------------------------
  def parse_commands( cmdlist )        
    loop = true                 # user input loop while true

        # parse command
    case ( cmdlist.first || ""  ).chomp
      when  "l", "list"      then  do_list( cmdlist )      # list rules
      when  "s", "status"    then  do_status    # print status

      when  "f", "flags"     then  do_flags( cmdlist )     # print flags
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

  #  ------------------------------------------------------------
  #  show_rules  -- display all rules in system
  #  ------------------------------------------------------------
  def show_rules()
    Environ.put_info ">>>>> cekimi rules; starting rule: #{@main_rule}"
    (list_m, list_s) = CekimiRules.list_rules
    Environ.put_info list_m
    Environ.put_info list_s  if Environ.flags.flag_full_rule


    if Environ.flags.flag_verb_trace
       puts :indef_past.to_s + ":  " + CekimiRules.get_rule( :indef_past ).to_s
    end
  end

  #  ------------------------------------------------------------
  #  do_list  -- handle list cmd: display and change conjugate start
  #  args:
  #    list  -- cli array, with cmd at top
  #  ------------------------------------------------------------
  def do_list(list)

    list.shift  # pop first element, the "l" command
    unless list.empty?
      rule = list.first

      if CekimiRules.has_rule?( rule )
      then 
        @main_rule = rule   # replacing starting rule
      else  
        Environ.log_warn "#{rule} invalid rule"
        Environ.put_info "#{rule} invalid rule"
      end
      
    end

    show_rules    # first display all rules

   end
  
  #  ------------------------------------------------------------
  #  do_status  -- display list of all cekimi rules
  #  ------------------------------------------------------------
  def do_status        
    Environ.put_info ">>>>> status #{ CekimiRules.cekimi_rules_count } rules"
  end

  #  ------------------------------------------------------------
  #  do_flags  -- display flag states
  #  args:
  #    list  -- cli array, with cmd at top
  #  ------------------------------------------------------------
  def do_flags(list)
    list.shift  # pop first element, the "f" command
    if ( Environ.flags.parse_flags( list ) )
      Environ.change_log_level( Environ.flags.flag_log_level )
    end

    Environ.put_info ">>>>>  flags: " + Environ.flags.to_s
  end

  #  ------------------------------------------------------------
  #  do_help  -- display help line
  #  ------------------------------------------------------------
  def do_help        
    Environ.put_info Environ.cekimi_help
    Environ.put_info Environ.flags.to_help
  end

  #  ------------------------------------------------------------
  #  do_version  -- display cekimi version
  #  ------------------------------------------------------------
  def do_version        
    Environ.put_info Environ.app_name + " v" + Environ.cekimi_version
  end

  #  ------------------------------------------------------------
  #  do_options  -- display any options
  #  ------------------------------------------------------------
  def do_options        
    Environ.put_info( ">>>>> options ")
  end

  #  ------------------------------------------------------------
  #  do_conjugate  -- kicks off a single conjugation rule
  #  args:
  #    list -- remaining cekimi cli token list
  #  ------------------------------------------------------------
  def do_conjugate( list )
    begin
      verb = Verb.new( list.shift )  # pop next entry; assume its a verb
      puts verb.to_s  if  Environ.flags.flag_verb_trace  # trace output if enabled
      next_key  = @main_rule           # rule key to kick of conjugation

  #  ------------------------------------------------------------
      # table_out holds the result
      until  next_key.nil?  
        (table_out, next_key) = CekimiRules.conjugate_by_key(verb, next_key, Environ.flags.flag_pair_conjugate )
        table_out.show_table Environ.flags.flag_pair_conjugate
           # end looping if not conjugate_chain OR there isn't a next_key
        next_key = nil if !Environ.flags.flag_chain_conjugate
      end
  #  ------------------------------------------------------------

    rescue ArgumentError
      Environ.put_and_log_error( ">>  " + $!.message )
    end  # exception handling

  end

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

end  # class CekimiWork
