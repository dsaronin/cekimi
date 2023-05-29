# 
# Çekimi conjugation rules objects
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
#

  require "yaml"
  require_relative "table_out"

class CekimiRules
  attr_accessor :caption_eng, :caption_turk, :grammar_role, :lexical_rule
  attr_accessor :parent_conj, :child_conj, :next_list, :rule_info, :exceptions
  attr_accessor :my_key, :my_table_out, :is_neg, :my_pair

  #  ------------------------------------------------------------
  #  CONSTANTS
  #  ------------------------------------------------------------

  LAST_VOWEL_REGEX = /[aeiouıöü][bcçdfgğhjklmnprsştvyz]*$/i
  VOICED_CONSONANTS   = /[bcdgğjlmnrvyz]/i
  UNVOICED_CONSONANTS = /[çfhkpsşt]/i

  D_CONS_REGEX   = /[aeiouıöübcdgğjlmnrvyz]/i
  T_CONS_REGEX   = /[çfhkpsşt]/i
  K_CONS_REGEX   = /k$/i
  D_CONS_SUFFIX  = "D" 
  T_CONS_SUFFIX  = "T"
  G_CONS_SUFFIX  = "Ğ"
  
  HARMONY_2WAY   = "2"  # two-way vowel harmony
  HARMONY_4WAY   = "4"  # four-way vowel harmony
  HARMONY_AORIST = "6"  # special case for aorist vowel harmony choices

  # preprocessing verb stem for causative, passive etc
  # these all construct a new infinitive
  PREPROC_REGEX  = /#(\w+)$/  # matches gitmek#a
  PP_ABILITY     = /a/i    # ability formation
  PP_CAUSATIVE   = /c/i    # causitive formation
  PP_PASSIVE     = /p/i    # passive formation
  PP_CAUSPASS    = /cp/i   # causitive-passive

  RULE_INFINITIVE =  '_infinitive'   # must match rule mnemonic
  RULE_ABILITY    =  'ability'   # must match rule mnemonic
  RULE_CAUSATIVE  =  'causative'   # must match rule mnemonic
  RULE_PASSIVE    =  'passive'   # must match rule mnemonic
  RULE_CAUSPASS   =  'causpass'   # must match rule mnemonic

  # inplace_operation REGEX for op switch
  VOWEL_HARMONY   =  /A/i    # 4way/2way vowel harmony op
  BUFFER_VOWEL    =  /Y/i    # add Y buffer for double vowel op
  DROP_VOWEL      =  /X/i    # drop vowel-stem final vowel op
  CONS_TRANSFORM  =  /K/i    # unvoiced > voiced consonent transform op
  TD_TRANSFORM    =  /D/i    # suffix changes depending stub consonant type
  KG_TRANSFORM    =  /G/i    # suffix changes when K before vowel

  # parse_rule REGEX for token switch
  STUB_RULE_REGEX     = /^~U/   # rule requesting stub buffer
  SWITCH_RULE_REGEX   = /^~S/   # rule matches last stub letter with a rule
  STEM_RULE_REGEX     = /^~V/   # rule requesting verb stem
  TD_STEM_RULE_REGEX  = /^~W/   # rule requesting voiced verb stem
  INFINITIVE_REGEX    = /^~Z/   # forms stub into inifinitive
  INVOKE_RULE_REGEX   = /^&(\w+)/  # recursive rule parse req
  ATOM_TOKEN_REGEX    = /\p{L}+/  # matches any alpha
  RULE_OP_REGEX       = /^@([AYKXDGZ])(\d)?/i # matches rule requesting an operation
      # side effect of matching: 
      #   $1 will be the op request
      #   $2 will be the sub-type of the op request
      # ex: @A4 -- request 4-way vowel harmony
      # ex: @Y  -- request vowel-vowel buffering

  

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  CLASS-LEVEL actions & methods
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  # initialize rules here if not already 

  @@cekimi_rules ||= YAML.unsafe_load_file( "app/rules.yml" )

  #  -----------------------------------------------------------------
  #  cekimi_rules_count  -- returns number of rules in hash
  #  -----------------------------------------------------------------

  def CekimiRules.cekimi_rules_count
    return @@cekimi_rules.size
  end

  #  -----------------------------------------------------------------
  #  cekimi_rules  -- returns hash of all rules
  #  TODO: needed?
  #  -----------------------------------------------------------------

  def CekimiRules.cekimi_rules
    return @@cekimi_rules
  end

  #  -----------------------------------------------------------------
  #  has_rule?  -- returns true if rule mnemonic is valid
  #  -----------------------------------------------------------------
  def CekimiRules.has_rule?( key )
    return @@cekimi_rules.has_key? key.to_sym
  end

  #  -----------------------------------------------------------------
  #  get_rule  -- returns the rule associated with a key
  #  args:
  #    rule_key -- key for lookup (will always be converted to sym)
  #  returns:
  #    rule object
  #  exception: 
  #    ArgumentError if rule not found
  #  -----------------------------------------------------------------

  def CekimiRules.get_rule( rule_key )
    Environ.log_debug( "searching for rule: #{rule_key}" )
    rule = @@cekimi_rules[ rule_key.to_sym ]
    return rule unless rule.nil?
    raise ArgumentError, "#{rule_key}: ÇekimiRule not found or undefined." 
  end

  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------

  private

  #  -----------------------------------------------------------------
  #  get_verb_obj  -- returns a verb obj for a given infinitive
  #     (here to DRY up the code)
  #  args:
  #    verb_str  -- string for verb to be processed
  #    verb_stem_neg  -- special stem for ABILITY negative cases
  #  -----------------------------------------------------------------
  def CekimiRules.get_verb_obj( verb_str, verb_stem_neg=nil )
    verb = Verb.new( verb_str, verb_stem_neg )  
    Environ.put_info verb.to_s  if  Environ.flags.flag_verb_trace  # trace output if enabled
    return verb
  end

  #  -----------------------------------------------------------------
  #  preprocess_verb  -- handles requests to remold verb infinitive
  #  such as for ability, causitive, passive, causitive-passive
  #  args:
  #    verb_str  -- cli verb string
  #    pdf  -- GenPdf obj for rendering
  #  -----------------------------------------------------------------
  def CekimiRules.preprocess_verb( verb_str, pdf )
    verb_stem_neg = nil   # assume normal case

    if verb_str =~ PREPROC_REGEX
    then
      pp_type = $1
      verb_str.sub!(PREPROC_REGEX, '')   # remove from verb
      rule_key = case pp_type
          when PP_ABILITY   then RULE_ABILITY
          when PP_CAUSATIVE then RULE_CAUSATIVE
          when PP_PASSIVE   then RULE_PASSIVE
          when PP_CAUSPASS  then RULE_CAUSPASS
      end   # case


      verb = CekimiRules.get_verb_obj( verb_str )
      (table_out, next_key) = CekimiRules.conjugate_by_key(verb, rule_key, false, pdf)
      verb_str = table_out.stub   # this becomes new infinitive

      verb_stem_neg = ( pp_type =~ PP_ABILITY  ? verb_str.sub(/bilmek$/i, "") : nil )
      puts ">>>>> new infinitive formed: #{verb_str}, neg_stem: #{verb_stem_neg} <<<<<<"
      table_out.verb_infinitive = verb_str.downcase  # replace infinitive

    end  # if preproc verb requested

    return CekimiRules.get_verb_obj( verb_str, verb_stem_neg )
  end

  public

  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------

  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  conjugate  -- full conjugate chain, yield output
  #  args:
  #    verb_str  -- string of verb to be processed
  #    start_rule  -- rule key to kick off conjugation chain
  #    pdf  -- a GenPdf object for rendering output
  #    block -- yielded for outputting result
  #  -----------------------------------------------------------------

  def CekimiRules.conjugate(verb_str, start_rule, pdf, &block)
    verb = CekimiRules.preprocess_verb( verb_str, pdf )  
    Environ.put_info verb.to_s  if  Environ.flags.flag_verb_trace  # trace output if enabled
    next_key  = start_rule          

    # table_out holds the result
    until  next_key.nil?  
      (table_out, next_key) = CekimiRules.conjugate_by_key(
        verb, next_key, Environ.flags.flag_pair_conjugate, pdf
      )
      yield table_out  # trigger table_out.show_table
         # end looping if not conjugate_chain OR there isn't a next_key
      next_key = nil if !Environ.flags.flag_chain_conjugate
    end
  end

  #  -----------------------------------------------------------------
  #  conjugate_by_key  -- starts conjugation of rule or pair
  #  args:
  #    verb:  verb obj for verb to be conjugated
  #    rule_key:  sym of rule key
  #    conjugate_pairs:  true if conjugate pairs of rules poz/neg
  #    pdf  -- GenPdf obj for rendering output
  #  returns:
  #    (table_out, next_key)
  #  -----------------------------------------------------------------

  def CekimiRules.conjugate_by_key(verb, rule_key, conjugate_pairs, pdf)
    rule = CekimiRules.get_rule( rule_key )

    table_out = rule.prep_and_parse( verb, conjugate_pairs, pdf )  # kicks off recursive descent parser
    Environ.log_debug( "#{rule_key} result: " + table_out.stub )
      
    return [table_out, rule.child_conj]
  end

  #  -----------------------------------------------------------------
  #  list_rules -- returns two strings of rule mnemonics
  #  returns: 
  #    [list_main, list_sub] -- list_main are the main rules, 
  #    list_sub are the non-main rules
  #  -----------------------------------------------------------------

  def CekimiRules.list_rules
    list_main = ""  # result for all primary rules
    list_sub  = ""  # result for subsidiary rules
    @@cekimi_rules.each_key do |key|
      if key  =~ /^_/ 
      then
      list_sub <<= key.to_s + ", "
      else
        list_main <<= key.to_s + ", "
      end  # if.then.else
    end  # do each
    return [list_main, list_sub]
  end

  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  INSTANCE METHODS
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------


  #  -----------------------------------------------------------------
  # prep_and_parse -- preps for recursive descent parsing
  # args: 
  #   my_conj_verb -- verb being conjugated
  #   conjugate_pairs  -- true if conjugate the negative/positive pairs
  #   pdf  -- GenPdf obj for rendering output
  # returns:
  #   @my_table_out: formed result for output
  #  -----------------------------------------------------------------
  def prep_and_parse( my_conj_verb, conjugate_pairs, pdf )
    parse_one_rule( my_conj_verb, pdf )
      # if need conjugate pairs and a pair-rule exists
    if conjugate_pairs  && 
       @my_pair  &&
       (rule = CekimiRules.get_rule( @my_pair.to_sym ))
    then  # conjugate the paired rule
      paired_table_out = rule.parse_one_rule( my_conj_verb, pdf )
          # and link the tables for output
      @my_table_out.pair_tables( paired_table_out )
    end
    return @my_table_out 
  end

  #  -----------------------------------------------------------------
  #  parse_one_rule  -- setup for recursive descent parsing
  #  args: 
  #    my_conj_verb -- verb being conjugated
  #    pdf  -- GenPdf obj for rendering output
  #  -----------------------------------------------------------------
  def parse_one_rule( my_conj_verb, pdf )
    Environ.log_debug( "starting parsing rule: #{@my_key}..." )
    @my_verb = my_conj_verb
    @my_table_out = TableOut.new( my_conj_verb, @caption_eng, @caption_turk, @grammar_role, @is_neg, pdf)
    parse_rule( )   # begins parsing a rule
    return @my_table_out 
  end

  #  ----------------------------------------------------------------
  #  to_s -- debuigging trace output for a CekimiRule object
  #  ----------------------------------------------------------------
  def to_s
    "#{@caption_eng}, #{@grammar_role},  #{@lexical_rule}, " + 
    "#{@rule_info}"
  end

  #  ----------------------------------------------------------------
  #  post_gen  -- post gen common handling
  #  ----------------------------------------------------------------
  def post_gen( str )
    # check for the last vowel and remember it
    if( idex = str.index LAST_VOWEL_REGEX ) then
      @my_table_out.last_vowel = str[idex].downcase   # becomes new last vowel
    end 
 
    puts "gen: #{@my_table_out.stub}"  if Environ.flags.flag_gen_trace
  end

  #  ----------------------------------------------------------------
  #  regen  -- replace the stub
  #  ----------------------------------------------------------------
  def regen( str )
    @my_table_out.stub = String.new( str )   # replace stub
    post_gen( str )
  end

 
  #  ----------------------------------------------------------------
  #  gen  -- append a suffix to the stub
  #  ----------------------------------------------------------------
  def gen( str )
    @my_table_out.stub << str   # append to stub
    post_gen( str )
  end

  #  ----------------------------------------------------------------
  #  parse_rule -- parses self's rule & generates conjugation
  #  recursive-descent parser
  #  output of parser is in the table_out.stub field
  #  assumption:
  #    @my_table_out  -- TableOut object for generating the conjugation
  #  ----------------------------------------------------------------
  def parse_rule( )
    parse_a_lexrule( @lexical_rule )  # parse self's lexical rule
  end

  #  ----------------------------------------------------------------
  #  parse_a_lexrule  -- parses a particular rule in the current context
  #  RECURSIVE!
  #  args: 
  #    lex_rule  -- a valid cekimi rule formed as an array
  #  ----------------------------------------------------------------
  def parse_a_lexrule( lex_rule )
    unless lex_rule.nil? then
      lex_rule.each  do  |token|
        case token
          when INFINITIVE_REGEX   then  form_infinitive
          when SWITCH_RULE_REGEX  then  do_switch_rule
          when INVOKE_RULE_REGEX  then  table_generation( $1 )
          when STEM_RULE_REGEX    then  choose_and_gen_verb_stem
          when STUB_RULE_REGEX    then  true  # nop; stub is valid
          when TD_STEM_RULE_REGEX then  gen @my_verb.verb_stem_td
          when RULE_OP_REGEX      then  prep_inplace_op( $1, $2 || "" )  
          when ATOM_TOKEN_REGEX   then  gen token
          when OUTPUT_RULE_REGEX  then  true  # nop
          else
            Environ.log_warn( "Rule token not found: #{token}; ignored." )
          end  # case
      end  # foreach token
    end  # unless @lexical_rule nil
  end

  #  ----------------------------------------------------------------
  #  do_switch_rule  -- uses rule_info in a cascading CASE-like
  #  statement to choose a rule for further processing
  #  ----------------------------------------------------------------
  def do_switch_rule()
    @rule_info.each  do  | (regex, need_poly, lex_rule) |

         # handle any exceptions first
      if @exceptions && (newstem = @exceptions[@my_verb.verb_stem.to_sym])
        regen( newstem )     # replace with exception
        break  # found matching rule; ignore remaining
      end

        # or handle in a regular manner
      #
      if @my_table_out.stub[-1] =~ Regexp.new( regex, Regexp::IGNORECASE ) then

        unless need_poly &&  @my_verb.stem_syllables == 1

          parse_a_lexrule( lex_rule )   # recursive here!
          break  # found matching rule; ignore remaining

        end  # unless polysyllable required but not poly syllable

      end  # matched a rule

    end  # outer loop:  each rule_info to check

  end

  #  ----------------------------------------------------------------
  #  choose_and_gen_verb_stem  -- special handling to choose stem
  #  ABILITY-extended verbs choose the verb stem differently for neg case
  #  ----------------------------------------------------------------
  def choose_and_gen_verb_stem
    gen (
      @is_neg && @my_verb.verb_stem_neg  ?  
      @my_verb.verb_stem_neg  :  
      @my_verb.verb_stem 
    )
  end

  #  ----------------------------------------------------------------
  #  prep_inplace_op-- preprocessing for in-place op if @A6
  #  args:
  #    op_type -- string for the type of inplace operation: A,K,X,Y
  #    op_subtype  -- digit to indicate subtype or blank, never nil!
  #  ----------------------------------------------------------------
  def prep_inplace_op(op_type, op_subtype)

    if op_type =~ VOWEL_HARMONY && op_subtype == HARMONY_AORIST
      # we're if if @A6 type of vowel_harmony logic for AORIST case
      op_subtype  =  case
        when @my_verb.stem_end_vowel then nil  # nop
        when @exceptions[@my_verb.verb_stem.to_sym] then HARMONY_4WAY
        when @my_verb.stem_syllables == 1 then HARMONY_2WAY
        when @my_verb.stem_syllables >  1 then HARMONY_4WAY
        else
          Environ.log_warn( "impossible A6 subtype encountered" )
          nil
      end  # end case statement
    end  # if aorist preprocessing for vowel harmony

    inplace_operation(op_type, op_subtype) unless op_subtype.nil?
  end

  #  ----------------------------------------------------------------
  #  inplace_operation -- handles an in-place alpha transformation
  #  args:
  #    op_type -- string for the type of inplace operation: A,K,X,Y
  #    op_subtype  -- [optional]: digit to indicate subtype
  #  ----------------------------------------------------------------
  def inplace_operation(op_type, op_subtype)
    case op_type
      when VOWEL_HARMONY   then  op_vowel_harmony( CekimiRules.get_rule( "_@#{op_type}#{op_subtype}".to_sym ) )
      when BUFFER_VOWEL    then  op_buffer_vowel
      when CONS_TRANSFORM  then  op_cons_transform
      when TD_TRANSFORM    then  op_td_transform
      when KG_TRANSFORM    then  op_kg_transform
      when DROP_VOWEL      then  op_drop_stem_vowel
      else
        Environ.log_warn( "in-place operation not found: #{token}; ignored." )
    end   #  case
  end

  #  ----------------------------------------------------------------
  #  op_vowel_harmony  -- does vowel harmony with last seen vowel
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_vowel_harmony( rule )
      # lookup corresponding harmony
    lookup = @my_table_out.last_vowel.to_sym
    vwl = rule.rule_info[ lookup ]
    if vwl then  # vowel harmony was found; use it
      gen vwl    # push to output queue
      @my_table_out.last_vowel = vwl   # becomes new last vowel
    else  # error: expected harmony not found
        Environ.log_warn( "vowel harmony key not found: #{lookup}; ignored." )
    end  # if.then.else check that harmony match found
  end

  #  ----------------------------------------------------------------
  #  op_buffer_vowel  -- adds buffer for vowel if last in stub
  #  ----------------------------------------------------------------
  def op_buffer_vowel
    if @my_table_out.stub[-1] =~ Verb::TURK_VOWEL_REGEX
      gen "Y"   # push buffer to queue
    end
  end

  #  ----------------------------------------------------------------
  #  op_cons_transform
  #  ----------------------------------------------------------------
  def op_cons_transform

  end

  #  ----------------------------------------------------------------
  #  op_td_transform  -- does the TD suffix transformation
  #  ----------------------------------------------------------------
  def op_td_transform
    if @my_table_out.stub[-1] =~ D_CONS_REGEX then
      gen D_CONS_SUFFIX
    else
      gen T_CONS_SUFFIX
    end

  end


  #  ----------------------------------------------------------------
  #  op_kg_transform  -- does the KĞ stem transformation
  #  ----------------------------------------------------------------
  def op_kg_transform
    if @my_table_out.stub[-1] =~ K_CONS_REGEX  then
      @my_table_out.stub.chop!   # remove the trailing K
      gen G_CONS_SUFFIX 
    end
  end


  #  ----------------------------------------------------------------
  #  op_drop_stem_vowel  -- drops a verb stem vowel
  #  ----------------------------------------------------------------
  def op_drop_stem_vowel
    if @my_verb.stem_end_vowel then
      @my_table_out.last_vowel = @my_verb.last_pure_vowel
      @my_table_out.stub.chop!   # remove the trailing vowl
    end
  end

  #  ----------------------------------------------------------------
  #  form_infinitive  -- turns stub into infinitive
  #  ----------------------------------------------------------------
  def form_infinitive()
    rule =  CekimiRules.get_rule( RULE_INFINITIVE.to_sym )
    rule.my_table_out = @my_table_out
    rule.parse_rule   # parse the infinitive rule
  end

  #  ----------------------------------------------------------------
  #  table_generation  -- generates a table of conjugations for
  #    all six personal cases
  #  ----------------------------------------------------------------
 
  def table_generation( rulekey )

    rule =  CekimiRules.get_rule( rulekey.to_sym )
    rule.my_table_out = @my_table_out

    restore_stub = String.new( @my_table_out.stub )  # remember stub
    stub_len = restore_stub.length
    # 
    # TODO? do we need to remember last_vowel also??
    #
    rule.rule_info.each do |pronoun, lexrule|
      rule.lexical_rule = lexrule
      rule.parse_rule  # parse a rule for person
      @my_table_out.conjugate(pronoun)
      @my_table_out.stub = restore_stub[0,stub_len]  # reset the stub

    end  # do each hash

  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
 
end  #class CekimiRules

