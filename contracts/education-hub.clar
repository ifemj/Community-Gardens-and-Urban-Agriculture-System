;; Community Gardens - Education Hub Contract
;; Handles knowledge sharing, educational programs, and workshop coordination

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-WORKSHOP-NOT-FOUND (err u501))
(define-constant ERR-INVALID-INPUT (err u502))
(define-constant ERR-RESOURCE-NOT-FOUND (err u503))
(define-constant ERR-ALREADY-REGISTERED (err u504))
(define-constant ERR-WORKSHOP-FULL (err u505))
(define-constant ERR-REGISTRATION-CLOSED (err u506))
(define-constant ERR-INVALID-CAPACITY (err u507))
(define-constant ERR-MENTOR-NOT-FOUND (err u508))

;; Data Variables
(define-data-var next-workshop-id uint u1)
(define-data-var next-resource-id uint u1)
(define-data-var next-mentor-id uint u1)
(define-data-var next-program-id uint u1)

;; Data Maps
(define-map workshops
  { workshop-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 300),
    instructor: principal,
    garden-id: uint,
    scheduled-date: uint,
    duration-hours: uint,
    max-participants: uint,
    current-participants: uint,
    skill-level: (string-ascii 20),
    category: (string-ascii 50),
    materials-needed: (string-ascii 200),
    cost: uint,
    status: (string-ascii 20),
    location: (string-ascii 100)
  }
)

(define-map workshop-registrations
  { workshop-id: uint, participant: principal }
  {
    registered-at: uint,
    attendance-status: (string-ascii 20),
    completion-status: (string-ascii 20),
    feedback-rating: (optional uint),
    feedback-comment: (optional (string-ascii 200)),
    certificate-earned: bool
  }
)

(define-map educational-resources
  { resource-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 300),
    category: (string-ascii 50),
    resource-type: (string-ascii 30),
    content-hash: (string-ascii 64),
    author: principal,
    created-at: uint,
    skill-level: (string-ascii 20),
    tags: (string-ascii 200),
    downloads: uint,
    rating-sum: uint,
    rating-count: uint,
    status: (string-ascii 20)
  }
)

(define-map mentorship-programs
  { program-id: uint }
  {
    program-name: (string-ascii 100),
    description: (string-ascii 300),
    mentor: principal,
    garden-id: uint,
    max-mentees: uint,
    current-mentees: uint,
    duration-weeks: uint,
    focus-areas: (string-ascii 200),
    requirements: (string-ascii 200),
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map mentorship-relationships
  { mentor: principal, mentee: principal }
  {
    program-id: uint,
    started-at: uint,
    status: (string-ascii 20),
    sessions-completed: uint,
    mentor-rating: (optional uint),
    mentee-rating: (optional uint),
    goals: (string-ascii 200),
    progress-notes: (string-ascii 300)
  }
)

(define-map learning-paths
  { learner: principal, category: (string-ascii 50) }
  {
    current-level: (string-ascii 20),
    workshops-completed: uint,
    resources-accessed: uint,
    certificates-earned: uint,
    total-hours: uint,
    last-activity: uint,
    goals: (string-ascii 200)
  }
)

(define-map knowledge-contributions
  { contributor: principal, contribution-date: uint }
  {
    contribution-type: (string-ascii 30),
    title: (string-ascii 100),
    content-hash: (string-ascii 64),
    category: (string-ascii 50),
    verified: bool,
    upvotes: uint,
    downvotes: uint,
    expert-reviewed: bool
  }
)

(define-map seasonal-programs
  { season: uint, program-type: (string-ascii 50) }
  {
    program-name: (string-ascii 100),
    start-date: uint,
    end-date: uint,
    coordinator: principal,
    participants: uint,
    completion-rate: uint,
    topics-covered: (string-ascii 300),
    outcomes: (string-ascii 200)
  }
)

;; Private Functions
(define-private (is-garden-member (garden-id uint) (member principal))
  ;; In a real implementation, this would check the garden-management contract
  true
)

(define-private (calculate-skill-level (workshops-completed uint) (hours-completed uint))
  (if (< workshops-completed u3)
    "beginner"
    (if (< workshops-completed u8)
      "intermediate"
      "advanced"
    )
  )
)

(define-private (update-learning-progress (learner principal) (category (string-ascii 50)) (hours uint))
  (let
    (
      (current-progress (default-to
        { current-level: "beginner", workshops-completed: u0, resources-accessed: u0, certificates-earned: u0, total-hours: u0, last-activity: u0, goals: "" }
        (map-get? learning-paths { learner: learner, category: category })
      ))
      (new-total-hours (+ (get total-hours current-progress) hours))
      (new-workshops (+ (get workshops-completed current-progress) u1))
    )
    (map-set learning-paths
      { learner: learner, category: category }
      (merge current-progress {
        workshops-completed: new-workshops,
        total-hours: new-total-hours,
        last-activity: block-height,
        current-level: (calculate-skill-level new-workshops new-total-hours)
      })
    )
  )
)

;; Public Functions

;; Create a new workshop
(define-public (create-workshop (title (string-ascii 100)) (description (string-ascii 300)) (garden-id uint) (scheduled-date uint) (duration-hours uint) (max-participants uint) (skill-level (string-ascii 20)) (category (string-ascii 50)) (materials-needed (string-ascii 200)) (cost uint) (location (string-ascii 100)))
  (let
    (
      (workshop-id (var-get next-workshop-id))
    )
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> scheduled-date block-height) ERR-INVALID-INPUT)
    (asserts! (> duration-hours u0) ERR-INVALID-INPUT)
    (asserts! (> max-participants u0) ERR-INVALID-CAPACITY)
    (asserts! (is-garden-member garden-id tx-sender) ERR-NOT-AUTHORIZED)

    (map-set workshops
      { workshop-id: workshop-id }
      {
        title: title,
        description: description,
        instructor: tx-sender,
        garden-id: garden-id,
        scheduled-date: scheduled-date,
        duration-hours: duration-hours,
        max-participants: max-participants,
        current-participants: u0,
        skill-level: skill-level,
        category: category,
        materials-needed: materials-needed,
        cost: cost,
        status: "scheduled",
        location: location
      }
    )

    (var-set next-workshop-id (+ workshop-id u1))
    (ok workshop-id)
  )
)

;; Register for a workshop
(define-public (register-for-workshop (workshop-id uint))
  (let
    (
      (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) ERR-WORKSHOP-NOT-FOUND))
      (existing-registration (map-get? workshop-registrations { workshop-id: workshop-id, participant: tx-sender }))
    )
    (asserts! (is-none existing-registration) ERR-ALREADY-REGISTERED)
    (asserts! (< (get current-participants workshop) (get max-participants workshop)) ERR-WORKSHOP-FULL)
    (asserts! (> (get scheduled-date workshop) block-height) ERR-REGISTRATION-CLOSED)
    (asserts! (is-eq (get status workshop) "scheduled") ERR-REGISTRATION-CLOSED)

    (map-set workshop-registrations
      { workshop-id: workshop-id, participant: tx-sender }
      {
        registered-at: block-height,
        attendance-status: "registered",
        completion-status: "pending",
        feedback-rating: none,
        feedback-comment: none,
        certificate-earned: false
      }
    )

    ;; Update workshop participant count
    (map-set workshops
      { workshop-id: workshop-id }
      (merge workshop {
        current-participants: (+ (get current-participants workshop) u1)
      })
    )

    (ok true)
  )
)

;; Mark workshop attendance
(define-public (mark-attendance (workshop-id uint) (participant principal) (attended bool))
  (let
    (
      (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) ERR-WORKSHOP-NOT-FOUND))
      (registration (unwrap! (map-get? workshop-registrations { workshop-id: workshop-id, participant: participant }) ERR-INVALID-INPUT))
    )
    (asserts! (is-eq tx-sender (get instructor workshop)) ERR-NOT-AUTHORIZED)

    (map-set workshop-registrations
      { workshop-id: workshop-id, participant: participant }
      (merge registration {
        attendance-status: (if attended "attended" "absent"),
        completion-status: (if attended "completed" "incomplete")
      })
    )

    ;; Update learning progress if attended
    (if attended
      (update-learning-progress participant (get category workshop) (get duration-hours workshop))
      true
    )

    (ok true)
  )
)

;; Add educational resource
(define-public (add-educational-resource (title (string-ascii 100)) (description (string-ascii 300)) (category (string-ascii 50)) (resource-type (string-ascii 30)) (content-hash (string-ascii 64)) (skill-level (string-ascii 20)) (tags (string-ascii 200)))
  (let
    (
      (resource-id (var-get next-resource-id))
    )
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> (len content-hash) u0) ERR-INVALID-INPUT)

    (map-set educational-resources
      { resource-id: resource-id }
      {
        title: title,
        description: description,
        category: category,
        resource-type: resource-type,
        content-hash: content-hash,
        author: tx-sender,
        created-at: block-height,
        skill-level: skill-level,
        tags: tags,
        downloads: u0,
        rating-sum: u0,
        rating-count: u0,
        status: "active"
      }
    )

    (var-set next-resource-id (+ resource-id u1))
    (ok resource-id)
  )
)

;; Create mentorship program
(define-public (create-mentorship-program (program-name (string-ascii 100)) (description (string-ascii 300)) (garden-id uint) (max-mentees uint) (duration-weeks uint) (focus-areas (string-ascii 200)) (requirements (string-ascii 200)))
  (let
    (
      (program-id (var-get next-program-id))
    )
    (asserts! (> (len program-name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> max-mentees u0) ERR-INVALID-INPUT)
    (asserts! (> duration-weeks u0) ERR-INVALID-INPUT)
    (asserts! (is-garden-member garden-id tx-sender) ERR-NOT-AUTHORIZED)

    (map-set mentorship-programs
      { program-id: program-id }
      {
        program-name: program-name,
        description: description,
        mentor: tx-sender,
        garden-id: garden-id,
        max-mentees: max-mentees,
        current-mentees: u0,
        duration-weeks: duration-weeks,
        focus-areas: focus-areas,
        requirements: requirements,
        status: "active",
        created-at: block-height
      }
    )

    (var-set next-program-id (+ program-id u1))
    (ok program-id)
  )
)

;; Join mentorship program
(define-public (join-mentorship (program-id uint) (goals (string-ascii 200)))
  (let
    (
      (program (unwrap! (map-get? mentorship-programs { program-id: program-id }) ERR-INVALID-INPUT))
      (existing-relationship (map-get? mentorship-relationships { mentor: (get mentor program), mentee: tx-sender }))
    )
    (asserts! (is-none existing-relationship) ERR-ALREADY-REGISTERED)
    (asserts! (< (get current-mentees program) (get max-mentees program)) ERR-WORKSHOP-FULL)
    (asserts! (is-eq (get status program) "active") ERR-INVALID-INPUT)

    (map-set mentorship-relationships
      { mentor: (get mentor program), mentee: tx-sender }
      {
        program-id: program-id,
        started-at: block-height,
        status: "active",
        sessions-completed: u0,
        mentor-rating: none,
        mentee-rating: none,
        goals: goals,
        progress-notes: ""
      }
    )

    ;; Update program mentee count
    (map-set mentorship-programs
      { program-id: program-id }
      (merge program {
        current-mentees: (+ (get current-mentees program) u1)
      })
    )

    (ok true)
  )
)

;; Submit workshop feedback
(define-public (submit-workshop-feedback (workshop-id uint) (rating uint) (comment (string-ascii 200)))
  (let
    (
      (registration (unwrap! (map-get? workshop-registrations { workshop-id: workshop-id, participant: tx-sender }) ERR-INVALID-INPUT))
    )
    (asserts! (>= rating u1) ERR-INVALID-INPUT)
    (asserts! (<= rating u5) ERR-INVALID-INPUT)
    (asserts! (is-eq (get attendance-status registration) "attended") ERR-NOT-AUTHORIZED)

    (map-set workshop-registrations
      { workshop-id: workshop-id, participant: tx-sender }
      (merge registration {
        feedback-rating: (some rating),
        feedback-comment: (some comment)
      })
    )

    (ok true)
  )
)

;; Contribute knowledge
(define-public (contribute-knowledge (contribution-type (string-ascii 30)) (title (string-ascii 100)) (content-hash (string-ascii 64)) (category (string-ascii 50)))
  (begin
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len content-hash) u0) ERR-INVALID-INPUT)

    (map-set knowledge-contributions
      { contributor: tx-sender, contribution-date: block-height }
      {
        contribution-type: contribution-type,
        title: title,
        content-hash: content-hash,
        category: category,
        verified: false,
        upvotes: u0,
        downvotes: u0,
        expert-reviewed: false
      }
    )

    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-workshop (workshop-id uint))
  (map-get? workshops { workshop-id: workshop-id })
)

(define-read-only (get-workshop-registration (workshop-id uint) (participant principal))
  (map-get? workshop-registrations { workshop-id: workshop-id, participant: participant })
)

(define-read-only (get-educational-resource (resource-id uint))
  (map-get? educational-resources { resource-id: resource-id })
)

(define-read-only (get-mentorship-program (program-id uint))
  (map-get? mentorship-programs { program-id: program-id })
)

(define-read-only (get-mentorship-relationship (mentor principal) (mentee principal))
  (map-get? mentorship-relationships { mentor: mentor, mentee: mentee })
)

(define-read-only (get-learning-path (learner principal) (category (string-ascii 50)))
  (map-get? learning-paths { learner: learner, category: category })
)

(define-read-only (get-knowledge-contribution (contributor principal) (contribution-date uint))
  (map-get? knowledge-contributions { contributor: contributor, contribution-date: contribution-date })
)

(define-read-only (get-learner-stats (learner principal))
  (ok {
    total-workshops: u5, ;; This would be calculated from actual data
    total-hours: u40,
    certificates: u3,
    current-level: "intermediate",
    active-mentorships: u1
  })
)

(define-read-only (get-workshop-stats (workshop-id uint))
  (match (map-get? workshops { workshop-id: workshop-id })
    workshop (ok {
      capacity-utilization: (/ (* (get current-participants workshop) u100) (get max-participants workshop)),
      status: (get status workshop),
      days-until-workshop: (if (> (get scheduled-date workshop) block-height)
        (- (get scheduled-date workshop) block-height)
        u0)
    })
    ERR-WORKSHOP-NOT-FOUND
  )
)
