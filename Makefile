BASE:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: deploy clean ensureadmin amq database terminal workshop rest username userprojects

deploy: ensureadmin amq database terminal rest workshop username userprojects
	@echo "Done"

amq:
	@$(BASE)/scripts/install_amq.sh

database:
	@$(BASE)/scripts/install_db.sh

rest:
	@$(BASE)/scripts/deploy_rest_service.sh

username:
	@$(BASE)/scripts/provision_get_a_username.sh

terminal:
	@$(BASE)/scripts/install_terminal.sh

workshop:
	@$(BASE)/scripts/install_workshop.sh

userprojects:
	@$(BASE)/scripts/setup_user_projects.sh

clean:
	@$(BASE)/scripts/clean_amq.sh
	@$(BASE)/scripts/clean_db.sh
	@$(BASE)/scripts/clean_terminal.sh
	@$(BASE)/scripts/clean_workshop.sh
	@$(BASE)/scripts/clean_rest_service.sh
	@$(BASE)/scripts/clean_get_a_username.sh
	@$(BASE)/scripts/clean_user_projects.sh
	-@oc delete project `grep DBPROJ $(BASE)/config.sh | sed -e 's/^.*=//'`
	-@oc delete project `grep AMQPROJ $(BASE)/config.sh | sed -e 's/^.*=//'`
	-@oc delete project `grep RESTPROJ $(BASE)/config.sh | sed -e 's/^.*=//'`
	-@oc delete project `grep GAUPROJ $(BASE)/config.sh | sed -e 's/^.*=//'`
	-@oc delete project `grep TERMPROJ $(BASE)/config.sh | sed -e 's/^.*=//'`
	-@oc delete project `grep WORKSHOPPROJ $(BASE)/config.sh | sed -e 's/^.*=//'`

# Non-admins would not be able to access the openshift namespace
ensureadmin:
	oc project openshift
