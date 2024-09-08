#!/bin/bash

echo 'Setting up project...'
mkdir -p .
mkdir -p src
mkdir -p src/main
mkdir -p src/main/java
mkdir -p src/main/java/com
mkdir -p src/main/java/com/idempiere
mkdir -p src/main/java/com/idempiere/erp
mkdir -p src/main/java/com/idempiere/erp/entity
mkdir -p src/main/java/com/idempiere/erp/config
mkdir -p src/main/java/com/idempiere/erp/aspect
mkdir -p src/main/java/com/idempiere/erp/controller
mkdir -p src/main/java/com/idempiere/erp/service
mkdir -p src/main/java/com/idempiere/erp/repository
mkdir -p src/main/java/com/idempiere/erp/model
mkdir -p src/main/java/com/idempiere/erp/strategy
mkdir -p src/main/resources
mkdir -p src/test
cat > src/main/java/com/idempiere/erp/entity/ADWindow.java << 'EOF'
package com.idempiere.erp.entity;

import lombok.Data;
import javax.persistence.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Entity
@Table(name = "ad_window")
@Data
public class ADWindow {
    @Id
    @Column(name = "ad_window_id")
    private BigDecimal adWindowId;

    @Column(name = "name")
    private String name;

    @Column(name = "created_by")
    private BigDecimal createdBy;

    @Column(name = "updated_by")
    private BigDecimal updatedBy;

    @OneToMany(mappedBy = "adWindow")
    private List<ADTab> tabs;

    @Transient
    private Map<String, String> dynamicFields = new HashMap<>();

    public String getDisplayValue(String fieldName) {
        return dynamicFields.get(fieldName + "_DisplayValue");
    }
}
EOF
cat > src/main/java/com/idempiere/erp/entity/ADTab.java << 'EOF'
package com.idempiere.erp.entity;

import lombok.Data;
import javax.persistence.*;
import java.math.BigDecimal;
import java.util.List;

@Entity
@Table(name = "ad_tab")
@Data
public class ADTab {
    @Id
    @Column(name = "ad_tab_id")
    private BigDecimal adTabId;

    @Column(name = "name")
    private String name;

    @ManyToOne
    @JoinColumn(name = "ad_window_id")
    private ADWindow adWindow;

    @OneToMany(mappedBy = "adTab")
    private List<ADField> fields;

    @ManyToOne
    @JoinColumn(name = "ad_table_id")
    private ADTable adTable;
}
EOF
cat > src/main/java/com/idempiere/erp/entity/ADTable.java << 'EOF'
package com.idempiere.erp.entity;

import lombok.Data;
import javax.persistence.*;
import java.math.BigDecimal;
import java.util.List;

@Entity
@Table(name = "ad_table")
@Data
public class ADTable {
    @Id
    @Column(name = "ad_table_id")
    private BigDecimal adTableId;

    @Column(name = "tablename")
    private String tableName;

    @OneToMany(mappedBy = "adTable")
    private List<ADColumn> columns;
}
EOF
cat > src/main/java/com/idempiere/erp/entity/ADColumn.java << 'EOF'
package com.idempiere.erp.entity;

import lombok.Data;
import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "ad_column")
@Data
public class ADColumn {
    @Id
    @Column(name = "ad_column_id")
    private BigDecimal adColumnId;

    @Column(name = "columnname")
    private String columnName;

    @Column(name = "ad_reference_id")
    private BigDecimal adReferenceId;

    @ManyToOne
    @JoinColumn(name = "ad_table_id")
    private ADTable adTable;
}
EOF
cat > src/main/java/com/idempiere/erp/entity/ADMenu.java << 'EOF'
package com.idempiere.erp.entity;

import lombok.Data;
import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "ad_menu")
@Data
public class ADMenu {
    @Id
    @Column(name = "ad_menu_id")
    private BigDecimal adMenuId;

    @Column(name = "name")
    private String name;

    @Column(name = "ad_window_id")
    private BigDecimal adWindowId;

    @Column(name = "ad_process_id")
    private BigDecimal adProcessId;
}
EOF
cat > src/main/java/com/idempiere/erp/entity/ADField.java << 'EOF'
package com.idempiere.erp.entity;

import lombok.Data;
import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "ad_field")
@Data
public class ADField {
    @Id
    @Column(name = "ad_field_id")
    private BigDecimal adFieldId;

    @Column(name = "name")
    private String name;

    @ManyToOne
    @JoinColumn(name = "ad_tab_id")
    private ADTab adTab;

    @ManyToOne
    @JoinColumn(name = "ad_column_id")
    private ADColumn adColumn;
}
EOF
cat > src/main/java/com/idempiere/erp/App.java << 'EOF'
package com.idempiere.erp;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        System.out.println( "Hello World!" );
    }
}
EOF
cat > src/main/java/com/idempiere/erp/config/JpaConfig.java << 'EOF'
package com.idempiere.erp.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import javax.sql.DataSource;
import java.util.Properties;

@Configuration
public class JpaConfig {

    @Bean
    public LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource dataSource) {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource);
        em.setPackagesToScan("com.idempiere.erp.entity");

        HibernateJpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);

        Properties properties = new Properties();
        properties.setProperty("hibernate.dialect", "org.hibernate.dialect.PostgreSQLDialect");
        properties.setProperty("hibernate.hbm2ddl.auto", "none");
        em.setJpaProperties(properties);

        return em;
    }

    @Bean
    public PlatformTransactionManager transactionManager(LocalContainerEntityManagerFactoryBean entityManagerFactory) {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory.getObject());
        return transactionManager;
    }
}
EOF
cat > src/main/java/com/idempiere/erp/aspect/ResolutionAspect.java << 'EOF'
package com.idempiere.erp.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.idempiere.erp.service.ResolutionService;
import java.util.List;

@Aspect
@Component
public class ResolutionAspect {
    @Autowired
    private ResolutionService resolutionService;

    @Around("@annotation(org.springframework.web.bind.annotation.GetMapping) || " +
            "@annotation(org.springframework.web.bind.annotation.PostMapping) || " +
            "@annotation(org.springframework.web.bind.annotation.PutMapping) || " +
            "@annotation(org.springframework.web.bind.annotation.DeleteMapping)")
    public Object resolveIds(ProceedingJoinPoint joinPoint) throws Throwable {
        Object result = joinPoint.proceed();

        if (result != null) {
            if (result instanceof List) {
                ((List<?>) result).forEach(resolutionService::resolveEntity);
            } else {
                resolutionService.resolveEntity(result);
            }
        }

        return result;
    }
}
EOF
cat > src/main/java/com/idempiere/erp/BackendApplication.java << 'EOF'
package com.idempiere.erp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan("com.idempiere.erp.entity")
@EnableJpaRepositories("com.idempiere.erp.repository")
public class BackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }
}EOF
cat > src/main/java/com/idempiere/erp/controller/FormMetadataController.java << 'EOF'
package com.idempiere.erp.controller;

import com.idempiere.erp.service.FormMetadataService;
import com.idempiere.erp.model.FormMetadataResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/forms")
public class FormMetadataController {
    
    @Autowired
    private FormMetadataService formMetadataService;

    @GetMapping("/{windowId}/metadata")
    public ResponseEntity<FormMetadataResponse> getFormMetadata(@PathVariable("windowId") String windowId) {
        FormMetadataResponse response = formMetadataService.getFormMetadata(windowId);
        return ResponseEntity.ok(response);
    }
}
EOF
cat > src/main/java/com/idempiere/erp/service/FormMetadataService.java << 'EOF'
package com.idempiere.erp.service;

import com.idempiere.erp.entity.*;
import com.idempiere.erp.repository.*;
import com.idempiere.erp.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FormMetadataService {

    @Autowired
    private ADWindowRepository adWindowRepository;

    @Autowired
    private ADTabRepository adTabRepository;

    public FormMetadataResponse getFormMetadata(String windowId) {
        ADWindow window = adWindowRepository.findById(new BigDecimal(windowId))
                .orElseThrow(() -> new RuntimeException("Window not found"));

        List<ADTab> tabs = adTabRepository.findByAdWindow(window);

        FormMetadataResponse response = new FormMetadataResponse();
        response.setWindowName(window.getName());
        response.setTabs(tabs.stream().map(this::mapTabToMetadata).collect(Collectors.toList()));

        return response;
    }

    private TabMetadata mapTabToMetadata(ADTab tab) {
        TabMetadata tabMetadata = new TabMetadata();
        tabMetadata.setTabName(tab.getName());
        tabMetadata.setFields(tab.getFields().stream().map(this::mapFieldToMetadata).collect(Collectors.toList()));
        return tabMetadata;
    }

    private FieldMetadata mapFieldToMetadata(ADField field) {
        FieldMetadata fieldMetadata = new FieldMetadata();
        fieldMetadata.setFieldName(field.getName());
        fieldMetadata.setColumnName(field.getAdColumn().getColumnName());
        fieldMetadata.setDisplayType(mapDisplayType(field.getAdColumn().getAdReferenceId()));
        return fieldMetadata;
    }

    private String mapDisplayType(BigDecimal adReferenceId) {
        // Implement mapping logic based on AD_Reference_ID
        return "String";
    }
}
EOF
cat > src/main/java/com/idempiere/erp/service/ResolutionService.java << 'EOF'
package com.idempiere.erp.service;

import com.idempiere.erp.strategy.ResolutionStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.lang.reflect.Field;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class ResolutionService {
    private final List<ResolutionStrategy> strategies;

    @Autowired
    public ResolutionService(List<ResolutionStrategy> strategies) {
        this.strategies = strategies;
    }

    public void resolveEntity(Object entity) {
        Class<?> clazz = entity.getClass();
        for (Field field : clazz.getDeclaredFields()) {
            field.setAccessible(true);
            try {
                Object value = field.get(entity);
                for (ResolutionStrategy strategy : strategies) {
                    if (strategy.canResolve(field, value)) {
                        String resolvedValue = strategy.resolve(field, value, entity);
                        setResolvedValue(entity, field.getName() + "_DisplayValue", resolvedValue);
                        break;
                    }
                }
            } catch (IllegalAccessException e) {
                // Handle exception
            }
        }
    }

    private void setResolvedValue(Object entity, String fieldName, String value) {
        try {
            Field field = entity.getClass().getDeclaredField("dynamicFields");
            field.setAccessible(true);
            @SuppressWarnings("unchecked")
            Map<String, String> dynamicFields = (Map<String, String>) field.get(entity);
            if (dynamicFields == null) {
                dynamicFields = new HashMap<>();
                field.set(entity, dynamicFields);
            }
            dynamicFields.put(fieldName, value);
        } catch (NoSuchFieldException | IllegalAccessException e) {
            // Handle exception
        }
    }
}
EOF
cat > src/main/java/com/idempiere/erp/repository/ADTableRepository.java << 'EOF'
package com.idempiere.erp.repository;

import com.idempiere.erp.entity.ADTable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;

public interface ADTableRepository extends JpaRepository<ADTable, BigDecimal> {
}
EOF
cat > src/main/java/com/idempiere/erp/repository/ADFieldRepository.java << 'EOF'
package com.idempiere.erp.repository;

import com.idempiere.erp.entity.ADField;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;

public interface ADFieldRepository extends JpaRepository<ADField, BigDecimal> {
}
EOF
cat > src/main/java/com/idempiere/erp/repository/ADMenuRepository.java << 'EOF'
package com.idempiere.erp.repository;

import com.idempiere.erp.entity.ADMenu;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;

public interface ADMenuRepository extends JpaRepository<ADMenu, BigDecimal> {
}
EOF
cat > src/main/java/com/idempiere/erp/repository/ADWindowRepository.java << 'EOF'
package com.idempiere.erp.repository;

import com.idempiere.erp.entity.ADWindow;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;

public interface ADWindowRepository extends JpaRepository<ADWindow, BigDecimal> {
}
EOF
cat > src/main/java/com/idempiere/erp/repository/ADColumnRepository.java << 'EOF'
package com.idempiere.erp.repository;

import com.idempiere.erp.entity.ADColumn;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;

public interface ADColumnRepository extends JpaRepository<ADColumn, BigDecimal> {
}
EOF
cat > src/main/java/com/idempiere/erp/repository/ADTabRepository.java << 'EOF'
package com.idempiere.erp.repository;

import com.idempiere.erp.entity.ADTab;
import com.idempiere.erp.entity.ADWindow;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;
import java.util.List;

public interface ADTabRepository extends JpaRepository<ADTab, BigDecimal> {
    List<ADTab> findByAdWindow(ADWindow adWindow);
}
EOF
cat > src/main/java/com/idempiere/erp/model/TabMetadata.java << 'EOF'
package com.idempiere.erp.model;

import lombok.Data;
import java.util.List;

@Data
public class TabMetadata {
    private String tabName;
    private List<FieldMetadata> fields;
}
EOF
cat > src/main/java/com/idempiere/erp/model/FormMetadataResponse.java << 'EOF'
package com.idempiere.erp.model;

import lombok.Data;
import java.util.List;

@Data
public class FormMetadataResponse {
    private String windowName;
    private List<TabMetadata> tabs;
}
EOF
cat > src/main/java/com/idempiere/erp/model/FieldMetadata.java << 'EOF'
package com.idempiere.erp.model;

import lombok.Data;

@Data
public class FieldMetadata {
    private String fieldName;
    private String columnName;
    private String displayType;
}
EOF
cat > src/main/java/com/idempiere/erp/strategy/ResolutionStrategy.java << 'EOF'
package com.idempiere.erp.strategy;

import java.lang.reflect.Field;

public interface ResolutionStrategy {
    boolean canResolve(Field field, Object value);
    String resolve(Field field, Object value, Object entity);
}
EOF
cat > src/main/java/com/idempiere/erp/strategy/UserResolutionStrategy.java << 'EOF'
package com.idempiere.erp.strategy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import java.lang.reflect.Field;
import java.math.BigDecimal;

@Component
public class UserResolutionStrategy implements ResolutionStrategy {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public boolean canResolve(Field field, Object value) {
        return (field.getName().equals("CreatedBy") || field.getName().equals("UpdatedBy")) &&
               (value instanceof BigDecimal || value instanceof Integer || value instanceof Long);
    }

    @Override
    public String resolve(Field field, Object value, Object entity) {
        String query = "SELECT Name FROM AD_User WHERE AD_User_ID = ?";
        return jdbcTemplate.queryForObject(query, String.class, value);
    }
}
EOF
cat > src/main/java/com/idempiere/erp/strategy/NumericIdResolutionStrategy.java << 'EOF'
package com.idempiere.erp.strategy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import java.lang.reflect.Field;
import java.math.BigDecimal;

@Component
public class NumericIdResolutionStrategy implements ResolutionStrategy {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public boolean canResolve(Field field, Object value) {
        return field.getName().endsWith("_ID") && 
               (value instanceof BigDecimal || value instanceof Integer || value instanceof Long);
    }

    @Override
    public String resolve(Field field, Object value, Object entity) {
        String tableName = field.getName().replace("_ID", "");
        String query = "SELECT Name FROM " + tableName + " WHERE " + tableName + "_ID = ?";
        return jdbcTemplate.queryForObject(query, String.class, value);
    }
}
EOF
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.14</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.idempiere.erp</groupId>
    <artifactId>backend</artifactId>
    <version>1.0-SNAPSHOT</version>
    <name>iDempiere ERP Backend</name>
    <description>Modern Spring Boot backend for iDempiere ERP</description>

    <properties>
        <java.version>11</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-core</artifactId>
            <version>5.6.14.Final</version>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-tools</artifactId>
            <version>5.6.14.Final</version>
        </dependency>
        <dependency>
            <groupId>javax.persistence</groupId>
            <artifactId>javax.persistence-api</artifactId>
            <version>2.2</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF
