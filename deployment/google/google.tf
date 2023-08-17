# ------------------------------------------------------
# MODULE INPUT
# ------------------------------------------------------

variable id {}
variable region {}

# ------------------------------------------------------
# UPLOAD DEPLOYMENT PACKAGES
# ------------------------------------------------------

resource "google_storage_bucket" "deployment_bucket" {
  name          = "deployment-packages-${var.region}-${var.id}"
  location      = var.region
  force_destroy = true
}

data "archive_file" "split_deployment_package" {
  type        = "zip"
  source_file = "${path.root}/split/target/deployable/split-1.0-SNAPSHOT.jar"
  output_path = "${path.root}/split/target/deployable/split-1.0-SNAPSHOT.zip"
}

data "archive_file" "extract_deployment_package" {
  type        = "zip"
  source_file = "${path.root}/extract/target/deployable/extract-1.0-SNAPSHOT.jar"
  output_path = "${path.root}/extract/target/deployable/extract-1.0-SNAPSHOT.zip"
}

data "archive_file" "translate_deployment_package" {
  type        = "zip"
  source_file = "${path.root}/translate/target/deployable/translate-1.0-SNAPSHOT.jar"
  output_path = "${path.root}/translate/target/deployable/translate-1.0-SNAPSHOT.zip"
}

data "archive_file" "synthesize_deployment_package" {
  type        = "zip"
  source_file = "${path.root}/synthesize/target/deployable/synthesize-1.0-SNAPSHOT.jar"
  output_path = "${path.root}/synthesize/target/deployable/synthesize-1.0-SNAPSHOT.zip"
}

data "archive_file" "merge_deployment_package" {
  type        = "zip"
  source_file = "${path.root}/merge/target/deployable/merge-1.0-SNAPSHOT.jar"
  output_path = "${path.root}/merge/target/deployable/merge-1.0-SNAPSHOT.zip"
}

resource "google_storage_bucket_object" "split_bucket_object" {
  name     = "split.zip"
  bucket   = google_storage_bucket.deployment_bucket.name
  source   = data.archive_file.split_deployment_package.output_path
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "google_storage_bucket_object" "extract_bucket_object" {
  name     = "extract.zip"
  bucket   = google_storage_bucket.deployment_bucket.name
  source   = data.archive_file.extract_deployment_package.output_path
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "google_storage_bucket_object" "translate_bucket_object" {
  name     = "translate.zip"
  bucket   = google_storage_bucket.deployment_bucket.name
  source   = data.archive_file.translate_deployment_package.output_path
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "google_storage_bucket_object" "synthesize_bucket_object" {
  name     = "synthesize.zip"
  bucket   = google_storage_bucket.deployment_bucket.name
  source   = data.archive_file.synthesize_deployment_package.output_path
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "google_storage_bucket_object" "merge_bucket_object" {
  name     = "merge.zip"
  bucket   = google_storage_bucket.deployment_bucket.name
  source   = data.archive_file.merge_deployment_package.output_path
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

# ------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------

resource "google_cloudfunctions_function" "split_function" {
  name                  = "split"
  runtime               = "java11"
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.deployment_bucket.name
  source_archive_object = google_storage_bucket_object.split_bucket_object.name
  trigger_http          = true
  entry_point           = "function.SplitFunction"
  timeout               = 500
}

resource "google_cloudfunctions_function" "extract_function" {
  name                  = "extract"
  runtime               = "java11"
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.deployment_bucket.name
  source_archive_object = google_storage_bucket_object.extract_bucket_object.name
  trigger_http          = true
  entry_point           = "function.ExtractFunction"
  timeout               = 500
}

resource "google_cloudfunctions_function" "translate_function" {
  name                  = "translate"
  runtime               = "java11"
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.deployment_bucket.name
  source_archive_object = google_storage_bucket_object.translate_bucket_object.name
  trigger_http          = true
  entry_point           = "function.TranslateFunction"
  timeout               = 500
}

resource "google_cloudfunctions_function" "synthesize_function" {
  name                  = "synthesize"
  runtime               = "java11"
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.deployment_bucket.name
  source_archive_object = google_storage_bucket_object.synthesize_bucket_object.name
  trigger_http          = true
  entry_point           = "function.SynthesizeFunction"
  timeout               = 500
}

resource "google_cloudfunctions_function" "merge_function" {
  name                  = "merge"
  runtime               = "java11"
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.deployment_bucket.name
  source_archive_object = google_storage_bucket_object.merge_bucket_object.name
  trigger_http          = true
  entry_point           = "function.MergeFunction"
  timeout               = 500
}

# ------------------------------------------------------
# IAM
# ------------------------------------------------------

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "split_invoker" {
  project        = google_cloudfunctions_function.split_function.project
  region         = google_cloudfunctions_function.split_function.region
  cloud_function = google_cloudfunctions_function.split_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "extract_invoker" {
  project        = google_cloudfunctions_function.extract_function.project
  region         = google_cloudfunctions_function.extract_function.region
  cloud_function = google_cloudfunctions_function.extract_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "translate_invoker" {
  project        = google_cloudfunctions_function.translate_function.project
  region         = google_cloudfunctions_function.translate_function.region
  cloud_function = google_cloudfunctions_function.translate_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "synthesize_invoker" {
  project        = google_cloudfunctions_function.synthesize_function.project
  region         = google_cloudfunctions_function.synthesize_function.region
  cloud_function = google_cloudfunctions_function.synthesize_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "merge_invoker" {
  project        = google_cloudfunctions_function.merge_function.project
  region         = google_cloudfunctions_function.merge_function.region
  cloud_function = google_cloudfunctions_function.merge_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
