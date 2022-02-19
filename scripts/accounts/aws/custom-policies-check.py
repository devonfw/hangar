import sys;
import json;

aplied_custom_policies=sys.argv[1]
desired_custom_policies_file=sys.argv[2]
applied_custom_policies_parsed = json.loads(aplied_custom_policies)

# Opening JSON file
f = open(desired_custom_policies_file)
 
# returns JSON object as a dictionary
desired_custom_policies_parsed = json.load(f)

#Loop all desired statements
for statement_desired in desired_custom_policies_parsed['Statement']:
    effect_desired=statement_desired['Effect']
    resource_desired=statement_desired['Resource']
    #Loop all desired actions
    for action_desired in statement_desired['Action']:
        is_applied=False
        for custompolicy in applied_custom_policies_parsed:
            #Loop all applied statements
            for statement_applied in custompolicy['PolicyDocument']['Statement']:
                effect_applied=statement_applied['Effect']
                resource_applied=statement_applied['Resource']
                if ((effect_applied == effect_desired) and ((resource_applied == resource_desired) or (resource_applied == "*"))):
                    for action_applied in statement_applied['Action']:
                        if action_applied == action_desired:
                            is_applied=True
                            break
                if is_applied:
                    break
            if is_applied:
                break
        if is_applied:
            print("APPLIED ",effect_desired,": ",action_desired)
        else:
            print("ERROR: NOT APPLIED ",effect_desired,": ",action_desired)
            sys.exit(1)
sys.exit(0)