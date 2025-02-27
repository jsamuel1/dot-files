#AWS Profile:
# - display current AWS_PROFILE name
# - displays yellow on red if profile name contains 'production' or
#   ends in '-prod'
# - displays black on green otherwise

# remove function prompt_aws() if it exists

unset prompt_aws

# Function to get AWS region from environment or config
get_aws_region() {
  # Cache variables to detect changes
  local cached_aws_region="$_CACHED_AWS_REGION"
  local cached_aws_default_region="$_CACHED_AWS_DEFAULT_REGION"
  local cached_aws_profile="$_CACHED_AWS_PROFILE"
  
  # Check if any of the environment variables have changed
  if [[ "$AWS_REGION" != "$cached_aws_region" || 
        "$AWS_DEFAULT_REGION" != "$cached_aws_default_region" || 
        "$AWS_PROFILE" != "$cached_aws_profile" || 
        -z "$_CACHED_REGION_RESULT" ]]; then
    
    local region
    
    # First check if AWS_REGION is set
    if [[ -n "$AWS_REGION" ]]; then
      region="$AWS_REGION"
    # Then check if AWS_DEFAULT_REGION is set
    elif [[ -n "$AWS_DEFAULT_REGION" ]]; then
      region="$AWS_DEFAULT_REGION"
    # Otherwise try to get it from AWS config
    else
      # If AWS_PROFILE is set, try to get region for that profile
      if [[ -n "$AWS_PROFILE" ]]; then
        region=$(aws configure get region --profile "$AWS_PROFILE" 2>/dev/null)
      fi
      
      # If still empty, try default profile
      if [[ -z "$region" ]]; then
        region=$(aws configure get region 2>/dev/null)
      fi
    fi
    
    # Update cache variables
    _CACHED_AWS_REGION="$AWS_REGION"
    _CACHED_AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"
    _CACHED_AWS_PROFILE="$AWS_PROFILE"
    _CACHED_REGION_RESULT="$region"
  fi
  
  echo "$_CACHED_REGION_RESULT"
}

# Function to convert AWS region to airport code
region_to_airport_code() {
  local region="$1"
  
  # Check if we have a cached result for this region
  if [[ "$region" == "$_CACHED_REGION_FOR_AIRPORT" && -n "$_CACHED_AIRPORT_CODE" ]]; then
    echo "$_CACHED_AIRPORT_CODE"
    return
  fi
  
  local code
  case "$region" in
    us-east-1)      code="iad" ;; # N. Virginia
    us-east-2)      code="cmh" ;; # Ohio
    us-west-1)      code="sfo" ;; # N. California
    us-west-2)      code="pdx" ;; # Oregon
    ca-central-1)   code="yul" ;; # Montreal
    eu-north-1)     code="arn" ;; # Stockholm
    eu-west-1)      code="dub" ;; # Ireland
    eu-west-2)      code="lhr" ;; # London
    eu-west-3)      code="cdg" ;; # Paris
    eu-central-1)   code="fra" ;; # Frankfurt
    eu-south-1)     code="mxp" ;; # Milan
    ap-northeast-1) code="nrt" ;; # Tokyo
    ap-northeast-2) code="icn" ;; # Seoul
    ap-northeast-3) code="kix" ;; # Osaka
    ap-southeast-1) code="sin" ;; # Singapore
    ap-southeast-2) code="syd" ;; # Sydney
    ap-southeast-3) code="cgk" ;; # Jakarta
    ap-south-1)     code="bom" ;; # Mumbai
    sa-east-1)      code="gru" ;; # São Paulo
    af-south-1)     code="cpt" ;; # Cape Town
    me-south-1)     code="bah" ;; # Bahrain
    *)              code="???" ;; # Unknown region
  esac
  
  # Cache the result
  _CACHED_REGION_FOR_AIRPORT="$region"
  _CACHED_AIRPORT_CODE="$code"
  
  echo "$code"
}

prompt_aws() {
  [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
  
  # Get the AWS region and convert to airport code
  local region=$(get_aws_region)
  local airport_code=""
  
  if [[ -n "$region" ]]; then
    airport_code="@$(region_to_airport_code "$region")"
  fi
  
  case "$AWS_PROFILE" in
    *-prod|*production*) prompt_segment "$AGNOSTER_AWS_PROD_BG" "$AGNOSTER_AWS_PROD_FG" "AWS: ${AWS_PROFILE:gs/%/%%}${airport_code}" ;;
    *) prompt_segment "$AGNOSTER_AWS_BG" "$AGNOSTER_AWS_FG" "AWS: ${AWS_PROFILE:gs/%/%%}${airport_code}" ;;
  esac
}