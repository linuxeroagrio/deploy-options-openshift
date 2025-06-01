# ¿oc new-app, Helm o ArgoCD? Las 7 formas (y media) de desplegar apps en OpenShift

Este repositorio acompaña al video de **Linuxero Agrio** titulado:

> **"¿oc new-app, Helm o ArgoCD? Las 7 formas (y media) de desplegar apps en OpenShift"**

Contiene ejemplos de 7 formas (y media) diferentes de desplegar aplicaciones en OpenShift.

---

## Estructura del repositorio

```
deploy-options-openshift
├── app-manifests
│   ├── deployment.yaml
│   ├── route.yaml
│   └── service.yaml
├── app-source
│   └── html
│       └── index.html
├── charts
│   ├── hello-chart
│   │   ├── charts
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── deployment.yaml
│   │   │   ├── _helpers.tpl
│   │   │   ├── route.yaml
│   │   │   ├── service.yaml
│   │   │   └── tests
│   │   │       └── test-connection.yaml
│   │   └── values.yaml
│   └── linuxero-agrio-helm-repo.yaml
├── Dockerfile
├── gitops
│   ├── 00.hello-argo-proj-appproject.yaml
│   └── 01.hello-app-prod-appargo.yaml
├── hello-operator-manifests
│   ├── 00.hello-operator-catalog.yaml
│   ├── 01.deploy-hello-operator-ns.yaml
│   ├── 02.hello-operator-og.yaml
│   ├── 03.hello-operator-sub.yaml
│   └── 04.hello-operator-instace-hellochart.yaml
├── kustomize
│   ├── base
│   │   ├── deployment.yaml
│   │   ├── kustomization.yaml
│   │   ├── route.yaml
│   │   └── service.yaml
│   └── overlays
│       ├── dev
│       │   ├── kustomization.yaml
│       │   └── patch-route.yaml
│       └── prod
│           ├── kustomization.yaml
│           ├── patch-deployment.yaml
│           └── patch-route.yaml
├── LICENSE
├── ocp-templates
│   └── template.yaml
├── pipelines
│   ├── 00.hello-cicd-ns.yaml
│   ├── 01.hello-dev-ns.yaml
│   ├── 02.hello-prod-ns.yaml
│   ├── 03.edit-hello-dev-rb.yaml
│   ├── 04.edit-hello-prod-rb.yaml
│   ├── 05.hello-ci-cd-source-workspace-pvc.yaml
│   ├── 06.image-registry-creds-secret.yaml
│   ├── 07.argocd-env-secret.yaml
│   ├── 08.argocd-env-configmap.yaml
│   ├── 09.hello-argo-proj-appproject.yaml
│   ├── 10.hello-app-prod-appargo.yaml
│   ├── 11.kics-scan-clustertask.yaml
│   ├── 12.trivy-scanner-task.yaml
│   ├── 13.curl-task.yaml
│   ├── 14.argocd-app-set-values-task.yaml
│   ├── 15.hello-pipeline.yaml
│   └── 16.hello-pipeline-deploy-pipelinerun.yaml
└── README.md
```

## Pre-requisitos

* Acceso a un clúster de OpenShift 4.16+ con OpenShift GitOps y OpenShift Pipelines desplegados y configurados. Puedes utilizar un sandbox de Red Hat en el enlace [Start exploring in the Developer Sandbox for free](https://developers.redhat.com/developer-sandbox)
* Instalación de la CLI de OpenShift [oc](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/)
* Instalación de la CLI [helm](https://helm.sh/docs/intro/install/)
* Instalación de la CLI [argocd](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
* Instalación de la CLI [tkn](https://tekton.dev/docs/cli/)

## Sobre el código de aplicación e imágenes de conytenedores

El código de la aplicación consta de un html que despliega un mensaje simple. Las imágenes de contenedor utilizadas para la aplicación y el operador son públicas y pueden encontrarse en el registro [Quay.io](https://quay.io/user/linuxeroagrio/). Para los últimos ejemplos será necesario que cuentes con tu propio registro en donde publicar al menos, la imagen de la aplicación.

## Contenido

Deberas hacer un clone de este repositorio para ajustar los valores de los manifiestos en los casos que aplique.

```bash
git clone https://github.com/linuxeroagrio/deploy-options-openshift.git

cd deploy-options-openshift
```

1. **oc new-app**  
   Despliegue rápido desde código fuente o imágenes.

   Se crea el proyecto de trabajo 

   ```bash
   oc new-project deploy-new-app
   ```

   Ejemplo 1: s2i con código

   ```bash
   # Despliegue
   oc new-app --name hello-s2i-code --strategy=source --context-dir app-source/html openshift/nginx:1.24-ubi9~https://github.com/linuxeroagrio/deploy-options-openshift.git

   # Validación de la construcción
   oc logs -f bc/hello-s2i-code

   # Validación de los recursos creados
   oc get deployments,pods,services

   # Creación de ruta
   oc expose service hello-s2i-code

   # Validación de la aplicación
   curl http://$(oc get routes hello-s2i-code -o jsonpath='{.spec.host}')
   ```

   Ejemplo 2: s2i con Dockerfile

   ```bash
   # Despliegue
   oc new-app --name hello-s2i-docker --strategy=docker --context-dir=. https://github.com/linuxeroagrio/deploy-options-openshift.git

   # Validación de la construcción
   oc logs -f bc/hello-s2i-docker

   # Validación de los recursos creados
   oc get deployments,pods,services

   # Creación de ruta
   oc expose service hello-s2i-docker

   # Validación de la aplicación
   curl http://$(oc get routes hello-s2i-docker -o jsonpath='{.spec.host}')
   ```

   Ejemplo 3: Desde imágen de contenedor

   ```bash
   # Despliegue
   oc new-app --name hello-image --image=quay.io/linuxeroagrio/hello:v1

   # Validación de los recursos creados
   oc get deployments,pods,services

   # Creación de ruta
   oc expose service hello-image

   # Validación de la aplicación
   curl http://$(oc get routes hello-image -o jsonpath='{.spec.host}')
   ```

2. **oc apply con YAML**  
   Aplicación de manifiestos Kubernetes/OpenShift puros.

   ```bash
   # Creacion del proyecto
   oc new-project deploy-manifests

   # Creación de los recursos
   oc apply -f app-manifests/

   # Validación de los recursos creados
   oc get deployments,pods,services,routes

   # Validación de la aplicación
   curl http://$(oc get routes hello -o jsonpath='{.spec.host}')
   ```

3. **Templates de OpenShift**  
   Plantillas parametrizables heredadas de OpenShift 3.x.

   ```bash
   # Creacion del proyecto
   oc new-project deploy-template

   # Creación de los recursos
   oc process -f ocp-templates/template.yaml --param APP_NAME=hello-template | oc apply -f -

   # Validación de los recursos creados
   oc get deployments,pods,services,routes

   # Validación de la aplicación
   curl http://$(oc get routes hello-template -o jsonpath='{.spec.host}')
   ```

4. **Helm**  
   Despliegue usando Helm charts.

   ```bash
   # Creacion del proyecto
   oc new-project deploy-helm

   # Instalación local
   helm install hello-helm ./charts/hello-chart

   # Validación de los recursos creados
   oc get deployments,pods,services,routes

   # Validación de la aplicación
   curl http://$(oc get routes hello-helm -o jsonpath='{.spec.host}')

   # Agregar Repositorio Remoto
   helm repo add linuxeroagrio-charts https://linuxeroagrio.github.io/helm-charts

   # Instalación remota con sobreescritura de parametros
   helm install hello-helm-replicas --set replicaCount=2 --version=0.1.0  linuxeroagrio-charts/hello-chart

   # Validación de los recursos creados
   oc get deployments,pods,services,routes

   # Validación de la aplicación
   curl http://$(oc get routes hello-helm-replicas -o jsonpath='{.spec.host}')
   ```

5. **Kustomize**  
   Overlays por entorno con configuración declarativa.

   ```bash
   # Creacion del proyecto
   oc new-project deploy-kustomize

   # Creación de los recursos de desarrollo
   oc apply -k kustomize/overlays/dev

   # Validación de los recursos creados para desarrollo
   oc get deployments,pods,services,routes -l -l app=hello-dev

   # Validación de la aplicación desarrollo
   curl http://$(oc get routes hello-dev -o jsonpath='{.spec.host}')

   # Creación de los recursos de producción
   oc apply -k kustomize/overlays/prod

   # Validación de los recursos creados para producción
   oc get deployments,pods,services,routes -l -l app=hello-prod

   # Validación de la aplicación producción
   curl http://$(oc get routes hello-prod -o jsonpath='{.spec.host}')
   ```

6. **Operators**  
   Despliegue de recursos personalizados (CRDs) mediante Operators.

   ```bash
   # Creación del catálogo de operadores
   oc create -f hello-operator-manifests/00.hello-operator-catalog.yaml

   # Creacion del proyecto
   oc create -f hello-operator-manifests/01.deploy-operator-ns.yaml
   oc project deploy-operator

   # Instalación del operador
   oc create -f hello-operator-manifests/02.hello-operator-og.yaml
   oc create -f hello-operator-manifests/03.hello-operator-sub.yaml
   watch oc get og,sub,ip,csv

   # Creación de los recursos
   oc create -f hello-operator-manifests/04.hello-operator-instace-hellochart.yaml

   # Validación de los recursos creados
   oc get deployments,pods,services,routes

   # Validación de la aplicación
   curl http://$(oc get routes hellochart-operator-instance-1 -o jsonpath='{.spec.host}')

   ## Opcionalmente se puede editar la configuración de la aplicación ejecutando
   oc edit hellocharts.charts.linuxero-agrio.com.mx hellochart-operator-instance-1
   ```

7. **ArgoCD**  
   GitOps con sincronización automática desde Git.

   ```bash
   # Creación de namespace de aplicación y etiquetado para permitir que argocd lo pueda gestionar
   oc create namespace deploy-hello-prod
   oc label namespace deploy-hello-prod argocd.argoproj.io/managed-by=openshift-gitops
   oc project deploy-hello-prod

   # Login de argocd (Ajustar a tus valores)
   argocd login ARGOCD_URL --skip-test-tls --grpc-web --username TU_USUARIO --password TU_PASSWORD

   # Creación de ArgoProject y Application
   oc create -f gitops/00.hello-argo-proj-appproject.yaml
   oc create -f gitops/01.hello-app-prod-appargo.yaml
   argocd app list

   # Sincronización de la aplicación argo (Creación/Actualizacion de recursos)
   argocd app sync hello-app-prod

   # Validación de los recursos creados
   oc get deployments,pods,services,routes
   ```


7.5. **Tekton Pipelines**  
   Despliegue como parte de una pipeline de CI/CD.

   * Edita el archivo `06.image-registry-creds-secret.yaml` colocando tu archivo de credenciales dockerconfigjson del registro donde cargaras tu imagen de contenedor.
   * Edita el archivo `07.argocd-env-secret.yaml` colocando el usuario y el password que utilizas para acceder a argocd.
   * Edita el archivo `08.argocd-env-configmap.yaml` colocando la URL de tu servidor argocd.
   * Edita el archivo `16.hello-pipeline-deploy-pipelinerun.yaml` y actualiza los campos `IMAGE_NAME` con el nombre completo de tu imagen sin tag; `IMAGE_TAG` con la etiqueta de tu imagen y `DEV_URL` con la URL de tu aplicación del ambiente desarrollo.

   ```bash
   # Creación de los recursos
   oc create -f pipelines

   # Validacion de la ejecución del pipeline
   tnk pipelinerun logs -f -n hello-cicd hello-pipeline-deploy

   # Opcionalmente puedes lanzar una nueva ejecución con el siguiente comando (Nota: Actualizar variablesde acuerdo a tu caso)
   tkn pipeline start \
    -p GIT_REPO_URL=https://github.com/linuxeroagrio/deploy-options-openshift.git \
    -p DOCKERFILE_PATH=./Dockerfile \
    -p IMAGE_NAME=YOUR_REGISTRY/YOUR_REPO_YOUR_IMAGE:NAME \
    -p IMAGE_TAG=YOUR_IMAGE_TAG \
    -p HELM_REPO_URL=https://linuxeroagrio.github.io/helm-charts \
    -p HELM_CHART_NAME=hello-chart \
    -p HELM_CHART_VERSION=0.1.0 \
    -p APP_NAME=hello \
    -p DEV_URL=YOUR_DEV_URL  \
    --use-param-defaults \
    -w name=hello-source-workspace,claimName=hello-ci-cd-source-workspace \
    -w name=image-registry-creds,secret=image-registry-creds \
    --showlog \
    --exit-with-pipelinerun-error \
    hello-pipeline
   ```

## Enlace al video
Puedes encontrar el video con la explicación de cada caso en el canal de YouTube [Linuxero Agrio](https://youtube.com/@linuxeroagrio).
