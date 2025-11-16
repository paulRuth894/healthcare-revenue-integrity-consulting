(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))

(define-data-var contract-admin principal tx-sender)

(define-map healthcare-providers
  { provider-id: uint }
  {
    name: (string-ascii 100),
    npi-number: uint,
    claim-volume: uint,
    compliance-score: uint,
    last-audit: uint
  }
)

(define-map charge-capture-analysis
  { provider-id: uint, analysis-id: uint }
  {
    total-charges: uint,
    captured-charges: uint,
    missed-charges: uint,
    recovery-potential: uint
  }
)

(define-map coding-accuracy-records
  { provider-id: uint, record-id: uint }
  {
    total-claims: uint,
    accurate-claims: uint,
    error-rate: uint,
    improvement-needed: uint
  }
)

(define-map compliance-monitoring
  { provider-id: uint, check-id: uint }
  {
    check-type: (string-ascii 50),
    status: (string-ascii 20),
    findings: uint,
    remediation-plan: (string-ascii 100)
  }
)

(define-data-var next-provider-id uint u0)
(define-data-var next-analysis-id uint u0)
(define-data-var next-record-id uint u0)
(define-data-var next-check-id uint u0)

(define-public (register-provider (name (string-ascii 100)) (npi uint) (volume uint))
  (let ((provider-id (var-get next-provider-id)))
    (begin
      (map-insert healthcare-providers
        { provider-id: provider-id }
        {
          name: name,
          npi-number: npi,
          claim-volume: volume,
          compliance-score: u100,
          last-audit: u1
        }
      )
      (var-set next-provider-id (+ provider-id u1))
      (ok provider-id)
    )
  )
)

(define-public (record-charge-capture (provider-id uint) (total uint) (captured uint) (missed uint) (recovery uint))
  (let ((analysis-id (var-get next-analysis-id)))
    (begin
      (map-insert charge-capture-analysis
        { provider-id: provider-id, analysis-id: analysis-id }
        {
          total-charges: total,
          captured-charges: captured,
          missed-charges: missed,
          recovery-potential: recovery
        }
      )
      (var-set next-analysis-id (+ analysis-id u1))
      (ok analysis-id)
    )
  )
)

(define-public (record-coding-accuracy (provider-id uint) (total-claims uint) (accurate uint) (error uint) (needed uint))
  (let ((record-id (var-get next-record-id)))
    (begin
      (map-insert coding-accuracy-records
        { provider-id: provider-id, record-id: record-id }
        {
          total-claims: total-claims,
          accurate-claims: accurate,
          error-rate: error,
          improvement-needed: needed
        }
      )
      (var-set next-record-id (+ record-id u1))
      (ok record-id)
    )
  )
)

(define-public (add-compliance-check (provider-id uint) (check-type (string-ascii 50)) (status (string-ascii 20)) (findings uint) (plan (string-ascii 100)))
  (let ((check-id (var-get next-check-id)))
    (begin
      (map-insert compliance-monitoring
        { provider-id: provider-id, check-id: check-id }
        {
          check-type: check-type,
          status: status,
          findings: findings,
          remediation-plan: plan
        }
      )
      (var-set next-check-id (+ check-id u1))
      (ok check-id)
    )
  )
)

(define-read-only (get-provider (provider-id uint))
  (map-get? healthcare-providers { provider-id: provider-id })
)

(define-read-only (get-charge-capture (provider-id uint) (analysis-id uint))
  (map-get? charge-capture-analysis { provider-id: provider-id, analysis-id: analysis-id })
)

(define-read-only (get-coding-accuracy (provider-id uint) (record-id uint))
  (map-get? coding-accuracy-records { provider-id: provider-id, record-id: record-id })
)

(define-read-only (get-compliance-check (provider-id uint) (check-id uint))
  (map-get? compliance-monitoring { provider-id: provider-id, check-id: check-id })
)