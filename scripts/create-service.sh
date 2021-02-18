#!/bin/bash
reverse() {
    declare -n arr="$1" rev="$2"
    for i in "${arr[@]}"
    do
        rev=("$i" "${rev[@]}")
    done
}

PATH_CREATION_MICROSERVICE=$1
WHICH_SERVICE_CREATE=$2
declare -a ACCEPTED_SERVICES=("authorizer" "layer" "microservice" "workflow" "sns" "sqs" "ssm")

if [[ -z "$PATH_CREATION_MICROSERVICE" ]] || [[ -z "$WHICH_SERVICE_CREATE" ]]
then
  echo "============================================================================================================="
  echo "*************************************************************************************************************"
  echo "Warning there was an error!!!!!!"
  echo "*************************************************************************************************************"
  echo "Please inform a valid PATH and which SERVICE to create"
  echo ""
  echo "use: npm run create-service <PATH> < authorizer | layer | microservice | workflow | sns | sqs | ssm > "
  echo "============================================================================================================="
  exit 1
fi

CONTAINS="false"
for i in "${ACCEPTED_SERVICES[@]}"
do
  if [ "$i" == "$WHICH_SERVICE_CREATE" ] ; then
    CONTAINS="true"
  fi
done

# Validando o tipo de serviço
if [[ $CONTAINS == "false" ]]; then # contains
  echo "============================================================================================================="
  echo "*************************************************************************************************************"
  echo "Warning there was an error!!!!!!"
  echo "*************************************************************************************************************"
  echo "Please inform a valid SERVICE to create"
  echo ""
  echo "use: npm run create-service <PATH> < authorizer | layer | microservice | workflow | sns | sqs | ssm > "
  echo "============================================================================================================="
  exit 1
fi

#removendo a barra inicial quando houver
if [[ ${PATH_CREATION_MICROSERVICE} =~ ^/ ]]; then
  PATH_CREATION_MICROSERVICE=$(echo "${PATH_CREATION_MICROSERVICE}"|sed 's/\///')
fi

FILEPATH=${PATH_CREATION_MICROSERVICE}
declare -a arrayPathsCreate

while [ ${FILEPATH} != "." ] && [ ${FILEPATH} != "/" ]; do
  arrayPathsCreate+=(${FILEPATH})
  FILEPATH=$( dirname "${FILEPATH}" )
done

# mudando a ordem do array para criar os diretorios de tras para frente
reverse arrayPathsCreate reversedArrayPathsCreate

if [[ ${reversedArrayPathsCreate[0]} != "src" ]]; then
  for i in ${!reversedArrayPathsCreate[@]}; do
    reversedArrayPathsCreate[$i]="src/${reversedArrayPathsCreate[$i]}"
  done
  reversedArrayPathsCreate=("src" "${reversedArrayPathsCreate[@]}")
fi

#criando as pastas informadas
for i in ${reversedArrayPathsCreate[@]}; do
  if [ ! -d "$i" ] && [ "$i" != ${reversedArrayPathsCreate[-1]} ]; then
    mkdir $i
  fi
done

#clonando o projeto para o path designado
git clone git@github.com:RichardUlissesGabriel/${WHICH_SERVICE_CREATE}-template-serverless.git ${reversedArrayPathsCreate[-1]}

cd ${reversedArrayPathsCreate[-1]}

#apagando os arquivos git
rm -rf .git
rm -rf .gitignore
