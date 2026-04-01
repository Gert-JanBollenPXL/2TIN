## 1. JPA Relationships Overview

In JPA, entities can be related in different ways:

| Relationship Type | Cardinality                   | Description                                     |
| ----------------- | ----------------------------- | ----------------------------------------------- |
| **@OneToOne**     | One entity ↔ One entity       | Each side references exactly one other.         |
| **@OneToMany**    | One entity ↔ Many entities    | One entity relates to many others.              |
| **@ManyToOne**    | Many entities ↔ One entity    | Many entities relate to the same single entity. |
| **@ManyToMany**   | Many entities ↔ Many entities | Both sides have collections of each other.      |

---

## 2. The Ownership Concept (`mappedBy`)

In **bidirectional relationships**, one side is the **owner** of the relationship, the other side is **inverse** (or mappedBy side):

* The **owner side** controls the database mapping (foreign keys or join tables).
* The **inverse side** maps to the owner side’s field using `mappedBy`.
* The `mappedBy` attribute tells JPA, **"the mapping is defined on the other side, on this field."**

Only the **owner side** is used to update the database relation (e.g., foreign keys).

---

## 3. Relationship Types and Mappings in Detail

### A. **One-to-One (`@OneToOne`)**

* Example: A user has one profile.
* **Foreign key** can be on either side.
* Usually mapped with `@OneToOne` on both sides or unidirectional on one side.

```java
@Entity
class User {
  @OneToOne
  @JoinColumn(name="profile_id") // FK in User table
  private Profile profile;
}

@Entity
class Profile {
  @OneToOne(mappedBy="profile") // Inverse side
  private User user;
}
```

* The side with `@JoinColumn` owns the relationship.
* `mappedBy` side is inverse and doesn’t own the FK.

---

### B. **One-to-Many (`@OneToMany`) / Many-to-One (`@ManyToOne`)**

* This is the most common relationship.
* Example: One `Order` has many `OrderItem`s; each `OrderItem` belongs to one `Order`.

```java
@Entity
class Order {
  @OneToMany(mappedBy = "order")
  private List<OrderItem> items;
}

@Entity
class OrderItem {
  @ManyToOne
  @JoinColumn(name = "order_id") // Foreign key in OrderItem table
  private Order order;
}
```

* `OrderItem` is the **owner side** (with FK column `order_id`).
* `Order` is the **inverse side** (`mappedBy = "order"`).
* The FK column is stored in the **many-side** (`OrderItem`).

---

### C. **Many-to-Many (`@ManyToMany`)**

* Example: Students and Courses — many students can attend many courses.
* Requires a **join table** to link both entities.

```java
@Entity
class Student {
  @ManyToMany
  @JoinTable(
    name = "student_course",
    joinColumns = @JoinColumn(name = "student_id"),
    inverseJoinColumns = @JoinColumn(name = "course_id")
  )
  private List<Course> courses;
}

@Entity
class Course {
  @ManyToMany(mappedBy = "courses")
  private List<Student> students;
}
```

* The owner side is the one **without `mappedBy`** (here, `Student`).
* `@JoinTable` defines the join table name and join columns.
* The inverse side has `mappedBy` referring to the owner's field.

---

## 4. Unidirectional vs Bidirectional

* **Unidirectional**: Only one entity has a reference to the other.

  * Example: `Order` has a list of `OrderItem`s, but `OrderItem` has no back reference.
  * Simpler but less flexible for querying.
* **Bidirectional**: Both entities reference each other.

  * Allows navigation from either side.
  * Requires careful `mappedBy` to avoid redundant join tables or extra foreign keys.

---

## 5. Summary Table for Ownership and Foreign Key Location

| Relationship Type         | Owner Side (where FK is)                   | Inverse Side             |
| ------------------------- | ------------------------------------------ | ------------------------ |
| One-to-One                | Side with `@JoinColumn`                    | Side with `mappedBy`     |
| One-to-Many / Many-to-One | Many-side entity (with FK column)          | One-side with `mappedBy` |
| Many-to-Many              | Side without `mappedBy` (has `@JoinTable`) | Side with `mappedBy`     |

---

## 6. Extra Tips

* Use `mappedBy` **only on the inverse side** to avoid JPA creating extra join tables or redundant FKs.
* Be mindful of **cascading** and **fetch types** (`EAGER` vs `LAZY`) in relationships.
* The owner side is the one where you **persist relationship changes** (add/remove associations).
